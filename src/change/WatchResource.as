package change
{
	import change.events.ResourceChangeEvent;
	
	import consts.Setting;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import helpers.F5Logger;
	import helpers.UrlParts;
	
	import org.hamcrest.core.throws;
	import org.hamcrest.object.nullValue;
	
	import webserver.WebServer;
	import webserver.messages.HTTPResponse;

	public class WatchResource
	{
		public var url:String;
		public var referers:Vector.<String> = new Vector.<String>([]);
		
		private var _sourceUrl:String;
		private var sourceUrlParts:UrlParts;
		private var _sourceFile:File;
		private var exists:Boolean;
		private var lastModify:Object;
		public var lastChangeTime:Number = BEFORE_INIT_TIME;
		
		public static const BEFORE_INIT_TIME:int = 1;
		public static const AFTER_INIT_TIME:int = 10;
		
	
		
		
		// for url change detect
		private var querying:Boolean = false;
		private var socket:Socket;
		private var responseData:ByteArray;
		private var lastSize:String;
		public var lastCookie:String = null;
		
		private var watcher:ChangesWatcher = ChangesWatcher.instance;
		
		private var l:F5Logger = new F5Logger( this, 'WatchResource' );
		
		public function WatchResource(url:String)
		{
			this.url = url;
		}
		
		
		public function get sourceUrl():String
		{
			return _sourceUrl;
		}
		
		public function set sourceUrl( val:String ):void
		{
			if ( val == _sourceUrl ) return;
			_sourceUrl = val;
			sourceUrlParts = UrlParts.parseAndCreate( sourceUrl );
			
			detectChange();
		}

		
		public function get sourceFile():File
		{
			return _sourceFile;
		}
		
		public function set sourceFile(value:File):void
		{
			if ( value == sourceFile ) return;			
			_sourceFile = value;
			
			detectChange();
		}
		
		public function addReferer( val:String ):void
		{
			if ( referers.indexOf( val ) > -1 ) return;
			referers.push( val );
		}
		
		
		
		public function detectChange():void
		{
			if ( !_sourceUrl && _sourceFile )
			{
				detectFileChange();
			}
			else if ( _sourceUrl && !_sourceFile )
			{
				var server:WebServer = WebServer.instance;
				if ( server.proxiesRouter && server.proxiesRouter.rootFolder ){
					var bounceFolder:File = server.proxiesRouter.rootFolder;
					var parts:UrlParts = UrlParts.parseAndCreate( _sourceUrl );
					var relativePath:String = UrlParts.ensureRelative( parts.path );
					var f:File = bounceFolder.resolvePath( relativePath );
					if ( f.exists ){
						_sourceFile = f;
						return detectChange();
					}
				}
				
				detectUrlChange();
			}
			else if (	_sourceUrl && _sourceFile )
			{
				var exts:Array = Setting.STATIC_EXTS;
				var ext:String = _sourceFile.extension;
				if ( ext && Setting.STATIC_EXTS.indexOf( ext.toLowerCase() ) > -1 ){
					detectFileChange();
				}else{
					detectUrlChange();
				}
			}
			
		}
		
		private function detectFileChange():void
		{
			l.log('detectFileChange', sourceFile.nativePath);
			if ( ! sourceFile ) return;
			
			// init
			if ( lastChangeTime <= BEFORE_INIT_TIME ){
				exists = sourceFile.exists;
				if ( exists ) lastModify = sourceFile.modificationDate.getTime();
				lastChangeTime = AFTER_INIT_TIME;
				return ;
			}
			
			//non init
			var changeType:String = null;
			if ( sourceFile.exists == exists)
			{
				if ( exists == true )
				{
					var mtime:Number = sourceFile.modificationDate.getTime();
					if ( mtime != this.lastModify ){
						changeType = ResourceChangeEvent.CHANGE;
						lastModify = mtime;
					}
				}
			}
			else
			{
				if ( sourceFile.exists == false )
				{
					changeType = ResourceChangeEvent.DEL;
				}
				else
				{
					changeType = ResourceChangeEvent.ADD;
					lastModify = sourceFile.modificationDate.getTime();
				}
				exists = sourceFile.exists;
			}
			
			if ( changeType )
			{
				this.lastChangeTime = ( new Date() ).getTime();
				this.watcher.reportChange( changeType, this );
			}
		}
		
		private function detectUrlChange():void
		{
			if ( this.querying ){
				l.log('skip detectUrlChange', sourceUrl);
				return ;
			}
			l.log('detectUrlChange', sourceUrl);
			
			var req:String = 
			'GET ' + sourceUrlParts.location + ' HTTP/1.1\r\n' + 
			'Accept: */*\r\n' + 
			'Host: '+ sourceUrlParts.host + ':' + sourceUrlParts.port + '\r\n' + 
			'Connection: close\r\n' + 
			'Accept-Encoding: deflate\r\n';
			if ( lastCookie ) {
				req += 'Cookie: ' + lastCookie + '\r\n';
			}
			req += '\r\n' ;

			socket = new Socket();
//			socket.addEventListener( Event.CONNECT, on_socket_CONNECT );
			socket.addEventListener( IOErrorEvent.IO_ERROR, on_socket_IO_ERROR);
			socket.addEventListener( ProgressEvent.SOCKET_DATA, on_socket_SOCKET_DATA )
			socket.addEventListener( Event.CLOSE, on_socket_CLOSE )
			
			this.querying = true;
			responseData = new ByteArray();
			socket.connect( sourceUrlParts.host, sourceUrlParts.port );
			socket.writeUTFBytes( req );
			socket.flush();
		}
		
		private function analyseResponseData():void
		{
			var response:HTTPResponse = HTTPResponse.loadAndCreate( responseData );
			
			var _exists:Boolean = false;
			if ( response.status.toString().substr(0,1) != '4' )
				_exists = true;
			var mtime:String = response.getHeader( 'Last-Modified' );
			var size:String = response.getHeader( 'Content-Length' );
			
			// for init
			if ( lastChangeTime <= BEFORE_INIT_TIME ){
				exists = _exists;
				lastModify = mtime;
				lastSize = size;
				
				lastChangeTime = AFTER_INIT_TIME;
				return ;
			}
			
			// non init
			var changeType:String;
			if ( exists == _exists )
			{
				if ( lastModify != mtime  || lastSize != size )
				{
					changeType = ResourceChangeEvent.CHANGE;
					lastModify = mtime;
					lastSize = size;
				}
			}
			else
			{
				if ( _exists == false )
				{
					changeType = ResourceChangeEvent.DEL;
				}
				else
				{
					changeType = ResourceChangeEvent.ADD;
					lastModify = mtime;
					lastSize = size;
				}
				exists = _exists;
			}
			
			if ( changeType )
			{
				lastChangeTime = ( new Date() ).getTime();
				watcher.reportChange( changeType, this );
			}
		}
		
		private function unbindSocketEvents():void
		{
//			socket.removeEventListener( Event.CONNECT, on_socket_CONNECT );
			socket.removeEventListener( IOErrorEvent.IO_ERROR, on_socket_IO_ERROR);
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, on_socket_SOCKET_DATA );
			socket.removeEventListener( Event.CLOSE, on_socket_CLOSE );
		}
		
		protected function on_socket_SOCKET_DATA(event:ProgressEvent):void
		{
			this.socket.readBytes( responseData, responseData.length, socket.bytesAvailable );
		}
		
		protected function on_socket_CLOSE(event:Event):void
		{
			unbindSocketEvents();
			this.socket = null;
			this.querying = false;
			this.analyseResponseData();
		}
		
		protected function on_socket_IO_ERROR(event:IOErrorEvent):void
		{
			unbindSocketEvents();
			try
			{
				socket.close();
			}
			finally
			{
				socket = null;	
			}
			querying = false;
		}

	}
}