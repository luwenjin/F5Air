package webserver
{
	import change.ChangesWatcher;
	
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import helpers.F5Logger;
	import helpers.FileType;
	import helpers.UrlParts;
	import helpers.Utils;
	
	import mx.events.Request;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.messaging.messages.HTTPRequestMessage;
	
	import org.hamcrest.object.nullValue;
	
	import webserver.events.RouterEvent;
	import webserver.messages.HTTPRequest;
	import webserver.respond.ChangesResponder;
	import webserver.routers.ApisRouter;
	import webserver.routers.AssetsRouter;
	import webserver.routers.BounceRouter;
	import webserver.routers.FilesRouter;
	import webserver.routers.IRouter;
	
	public class WebServer extends EventDispatcher
	{
		private var server:ServerSocket;
		
		private var watcher:ChangesWatcher = ChangesWatcher.instance;
		public var rootUrl:String;
		
		private var _rootFolder:File;
		private var _proxyHost:String;
		private var _proxyPort:Number;
		
		public var host:String = '127.0.0.1';
		public var port:Number;
		
		private static const _instance:WebServer = new WebServer();
		
		public static const STATIC:String = 'static';
		public static const DYNAMIC:String = 'dyanmic';
		
		private var internalRouters:Vector.<IRouter> = new Vector.<IRouter>();
		public var filesRouter:FilesRouter;
		public var proxiesRouter:BounceRouter;
		
		private var l:F5Logger = new F5Logger(this, 'WebServer');
		

		public function WebServer()
		{
			if ( _instance != null )
			{
				throw new Error('Please use the instance property to access.');
			}
			
			this.server = new ServerSocket();
			this.server.addEventListener( ServerSocketConnectEvent.CONNECT, on_CONNECT );
			this.server.addEventListener( Event.CLOSE, on_CLOSE );
			
			this.internalRouters.push( new ApisRouter() );
			this.internalRouters.push( new AssetsRouter() );
		}
		
		public function get mode():String{
			if ( proxiesRouter ){
				return DYNAMIC;
			}else if ( filesRouter ){
				return STATIC;
			}else{
				return null;
			}
		}
		
		protected function on_CLOSE(event:Event):void
		{
			l.log( 'on_CLOSE' );
		}
		
		public static function get instance():WebServer
		{
			return _instance;
		}
		
		public function set rootFolder( folder:File ):void
		{
			if ( folder )
			{
				this._rootFolder = folder;
				this.filesRouter = new FilesRouter( folder, '/' );
				this.proxiesRouter = null;
				
				this.dispatchEvent( new RouterEvent( RouterEvent.ADD, this.filesRouter ) );
			}
			else
			{
				this.dispatchEvent( new RouterEvent( RouterEvent.REMOVE, this.filesRouter ) );
				
				this._rootFolder = null;
				this.filesRouter = null;
			}
		}
		
		public function get rootFolder():File
		{
			return this._rootFolder;	
		}
		
		public function set rootProxy( url:String ):void
		{
			if ( url )
			{
				var parts:UrlParts = UrlParts.parseAndCreate( url );	
				this._proxyHost = parts.host;
				this._proxyPort = parts.port;	
				this.proxiesRouter = new BounceRouter( parts.host, parts.port );
				this.proxiesRouter.addTreeNode( parts );
				this.filesRouter = null;
				
				this.dispatchEvent( new RouterEvent( RouterEvent.ADD, this.proxiesRouter ) );
			}
			else
			{
				this.dispatchEvent( new RouterEvent( RouterEvent.REMOVE, this.proxiesRouter ) );
				this._proxyHost = null;
				this._proxyPort = -1;
				this.proxiesRouter = null;
			}
		}
		
		public function get rootProxy():String
		{
			if ( this.proxiesRouter )
				return this._proxyHost + ':' + this._proxyPort;
			else
				return null;
		}
		
		public function ensureStart( port:Number=80 ):void
		{
			this.watcher.clear();
			if ( !this.server.listening )
			{
				this.port = port;
				while (true){
					try{
						this.server.bind( this.port );
						this.server.listen();
						this.watcher.start();
						if (this.port == 80)
							this.rootUrl = 'http://'+this.host + '/';
						else
							this.rootUrl = 'http://'+this.host+':'+this.port.toString() + '/';
						break;
					}catch( error: Error){
						this.port += 1;
						if ( this.port >= 87 && this.port < 1000 ) this.port = 8000;
					}
				}
			}
		}
		
		public function stop():void
		{
			this.watcher.stop();
			if ( this.server.listening ) 
			{
				this.server.close();
			}
					
		}
		
		protected function on_CONNECT(event:ServerSocketConnectEvent):void
		{
			l.log( 'on_CONNECT' );
			watcher.pause(1000);
			var socket:Socket = event.socket;
			socket.addEventListener( ProgressEvent.SOCKET_DATA, on_SOCKET_DATA );
		}
		
		protected function on_SOCKET_DATA(event:ProgressEvent):void
		{
//			try
//			{
				l.log( 'on_SOCKET_DATA' );
				var socket:Socket = event.target as Socket;
				socket.removeEventListener( ProgressEvent.SOCKET_DATA, on_SOCKET_DATA );
				
				var request:HTTPRequest = new HTTPRequest( socket );
				
				for each ( var router:IRouter in this.internalRouters)
				{
					if ( router == null ) continue;
					
					if ( router.rule.test( request.path ) )
					{
						router.handleRequest( request );
						return;
					}
				}
				
				if ( this.filesRouter && this.filesRouter.rule.test( request.path ) )
					this.filesRouter.handleRequest( request );
				else if ( this.proxiesRouter && this.proxiesRouter.rule.test( request.path ) )
					this.proxiesRouter.handleRequest( request );
//			}
//			catch( error:Error )
//			{
//				trace(error);
//			}
		}
	}
}