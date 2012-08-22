package webserver.respond
{
	import change.ChangesWatcher;
	import change.WatchResource;
	
	import com.adobe.net.DynamicURLLoader;
	import com.adobe.protocols.dict.Response;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import helpers.F5Logger;
	import helpers.FileType;
	import helpers.Utils;
	
	import webserver.messages.HTTPRequest;
	import webserver.messages.HTTPResponse;
	import webserver.respond.files.HtmlFileResponse;

	public class BounceResponder
	{	
		private var request:HTTPRequest;
		private var originHost:String;
		private var originPort:Number;
		
		private var buffer:ByteArray;
		
		private var socket:Socket;
		
//		private var l:F5Logger = new F5Logger( this, 'ProxyResponse' );
		
		private var watcher:ChangesWatcher = ChangesWatcher.instance;
		
		
		public function BounceResponder( request:HTTPRequest, originHost:String, originPort:Number )
		{
			this.request = request;
			this.originHost = originHost;
			this.originPort = originPort;
			
			var raw:String = request.raw;
			raw = raw.replace( /HTTP\/1.1/ , 'HTTP/1.0' );
			raw = raw.replace( /Host: .*?\r\n/ , 'Host: '+this.originHost+':'+this.originPort+'\r\n' );
			raw = raw.replace( /Accept-Encoding: .*?\r\n/ , 'Accept-Encoding: deflate\r\n' );
			raw = raw.replace( /Connection: .*?\r\n/ , 'Connection: close\r\n' ); // keep-alive mode is hard to detect EOF

			socket = new Socket();
			socket.addEventListener( Event.CONNECT, on_CONNECT );
			socket.addEventListener( ProgressEvent.SOCKET_DATA, on_SOCKET_DATA );
			socket.addEventListener( Event.CLOSE, on_CLOSE );
			socket.connect( this.originHost, this.originPort );
			socket.writeUTFBytes( raw );
			socket.flush();

		}
		
		protected function on_CLOSE(event:Event=null):void
		{
			this.buffer.position = 0;
			var response:HTTPResponse = HTTPResponse.loadAndCreate( this.buffer );
			response.setHeader( 'Connection', 'close' );
			response.setHeader( 'Transfer-Encoding', null);
			response.setHeader( 'Vary', null);
			response.setHeader( 'Accept-Ranges', null);
			response.setHeader( 'Pragma', 'no-cache' );
			response.setHeader( 'Cache-Control', 'no-cache, must-revalidate' );
			
			/*
			test:
			http://www.jiaoshoutv.com
			
			*/
			
//			response.setHeader( 'Vary', null );
			response.ver = '1.0';
			
			this.processWatching(response);
			this.processInject( response );
			
			this.socket.removeEventListener(ProgressEvent.SOCKET_DATA, on_SOCKET_DATA);
			this.socket.removeEventListener(Event.CLOSE, on_CLOSE);
			this.socket.removeEventListener(Event.CONNECT, on_CONNECT);
			
			if ( this.socket.connected )
			{
				this.socket.close();
				this.socket = null;
				this.buffer = null;
			}
			
			if ( request.socket.connected )
			{
				request.socket.writeBytes( response.dump() );
				request.socket.flush();
				request.socket.close();	
				request.socket = null;
				request = null;
			}
		}
		
		private function processInject(response:HTTPResponse):void
		{
			var html_mime:String = FileType.getMimeType( '.html' );
			if ( request.method == 'GET' && response.content_type && response.content_type.indexOf( html_mime ) > -1 )
			{
				//Content-Type可能带有charset=xxx
				var js:String = '<script src="/con/assets/js/jquery-1.6.3.min.js" type="text/javascript"></script>'
					+ '<script src="/con/assets/js/br.js" type="text/javascript"></script>\n';

				var i:int = HtmlFileResponse.findHtmlTag( response.body );
				var ba:ByteArray = new ByteArray();
				
				if ( i>0 )
				{
					ba.writeBytes( response.body, 0, i );
					ba.writeUTFBytes( js );
					ba.writeBytes( response.body, i, response.body.length-i );
				}
				else
				{
					ba.writeUTFBytes( js );
					ba.writeBytes( response.body, 0, response.body.length );
				}
				response.body = ba;
			}
		}
		
		protected function processWatching(response:HTTPResponse):void
		{
			var ext:String = Utils.getExtension( request.path );
			var source:String = request.url.replace(/http:\/\/.*?\//, 'http://'+this.originHost+':'+this.originPort+'/' );
			
			if ( request.method == 'GET' )
			{
				var referer:String = request.headers['Referer'];
				this.watcher.add( request.url, source, referer, request );
				
				if ( ! referer && response.content_type == FileType.getMimeType( '.html' ) )
					this.watcher.add( request.url, source, request.url, request );
				
				if ( response.content_type == FileType.getMimeType( '.css' ) && referer &&  Utils.getExtension( referer ).toLowerCase() == 'css' )
				{
					var resource:WatchResource = this.watcher.getResource( referer );
					for each ( var ref_url:String in resource.referers )
						this.watcher.add( request.url, source, ref_url, request );
				}
			}
		}

		
		protected function on_SOCKET_DATA(event:Event):void
		{
			while ( socket && socket.connected && socket.bytesAvailable ) {
				var ba:ByteArray = new ByteArray();
				socket.readBytes( ba, 0, socket.bytesAvailable );
				ba.position = 0;
				this.buffer.writeBytes( ba );
			}
		}
		
		protected function on_CONNECT(event:Event):void
		{
			this.buffer = new ByteArray();
		}
		
	}
}