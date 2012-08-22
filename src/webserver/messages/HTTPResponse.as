package webserver.messages
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.elements.BreakElement;
	
	import org.httpclient.HttpResponse;

	public class HTTPResponse extends HTTPMessageBase
	{
		
		public static const STATUS_MAP:Object = {
			100: 'Continue',
			101: 'Switching Protocols',
			
			200: 'OK',
			201: 'Created',
			202: 'Accepted',
			203: 'Non-Authoritative Information',
			204: 'No Content',
			205: 'Reset Content',
			206: 'Partial Content',
			
			300: 'Multiple Choices',
			301: 'Moved Permanently',
			302: 'Found',
			303: 'See Other',
			304: 'Not Modified',
			305: 'Use Proxy',
			306: '(Unused)',
			307: 'Temporary Redirect',
			
			400: 'Bad Request',
			401: 'Unauthorized',
			402: 'Payment Required',
			403: 'Forbidden',
			404: 'Not Found',
			405: 'Method Not Allowed',
			406: 'Not Acceptable',
			407: 'Proxy Authentication Required',
			408: 'Request Timeout',
			409: 'Conflict',
			410: 'Gone',
			411: 'Length Required',
			412: 'Precondition Failed',
			413: 'Request Entity Too Large',
			414: 'Request-URI Too Long',
			415: 'Unsupported Media Type',
			416: 'Requested Range Not Satisfiable',
			417: 'Expectation Failed',
			
			500: 'Internal Server Error',
			501: 'Not Implemented',
			502: 'Bad Gateway',
			503: 'Service Unavailable',
			504: 'Gateway Timeout',
			505: 'HTTP Version Not Supported'
		}
			
		public var status:int = -1;
		public var reason:String;
		public var ver:String = '1.1';
		
		public function HTTPResponse( status:int=200 )
		{
			this.status = status;
			this.reason = HTTPResponse.STATUS_MAP[ status ];
			this.body = new ByteArray();
		}
		
		public function get connection():String
		{
			return getHeader( 'Connection' );
		}

		public function set connection(value:String):void
		{
			setHeader( 'Connection', value );
		}

		public function get content_type():String
		{
			return getHeader( 'Content-Type' );
		}

		public function set content_type(value:String):void
		{
			setHeader( 'Content-Type', value );
		}

		public function dump():ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			var startLine:String = [ 'HTTP/'+ver, this.status.toString(), this.reason ].join(' ') +'\r\n';
			
			if ( !this.connection ) this.connection = 'close';
			this.headers['Content-Length'] = this.body.length.toString();
			
			bytes.writeUTFBytes( startLine );
//			bytes.writeUTFBytes( 'Cache-Control: public, max-age=43200\n');
//			bytes.writeUTFBytes( 'Expires: Wed, 28 Sep 2011 01:07:15 GMT\n');
//			bytes.writeUTFBytes( 'ETag: "flask-1315551952.0-33894-420942835"\n');
//			bytes.writeUTFBytes( 'Last-Modified: Fri, 09 Sep 2011 07:05:52 GMT\n');
//			bytes.writeUTFBytes( 'Keep-Alive: timeout=5, max=100\r\n');
//			bytes.writeUTFBytes( 'Connection: Keep-Alive\r\n');
			//todo: use keep-alive mode to get faster, ref: flask
			
			for ( var key:String in this.headers )
				bytes.writeUTFBytes( key + ': ' + headers[key] + '\r\n' );
			bytes.writeUTFBytes( '\r\n' );
			
			body.position = 0;
			bytes.writeBytes( body );
			
			bytes.position = 0;
			return bytes;
		}
		
		public static function loadAndCreate( buffer:ByteArray ):HTTPResponse
		{
			var headData:ByteArray = new ByteArray();
			var bodyData:ByteArray = new ByteArray();
			
			var headEnd:int = findHeadEnd( buffer );
			
			buffer.position = 0;
			buffer.readBytes( headData, 0, headEnd );
			
			buffer.position = headEnd;
			buffer.readBytes( bodyData, 0 );
			
			headData.position = 0;
			bodyData.position = 0;
			
			var headText:String = headData.readUTFBytes(headData.length);
			var lines:Array = headText.split('\r\n');
			
			var line:String = lines.shift() as String;
			var items:Array = line.split(' ');
			items.shift();
			var status:String = items.shift();
			var reason:String = items.join(' ');
			
			var response:HTTPResponse = new HTTPResponse( int( status ) );
			response.reason = reason;
			response.headers = parseHeaders( lines );
			response.body = bodyData;

			return response;
		}
		
		public function send( socket:Socket ):void
		{
			socket.writeBytes( this.dump() );
			socket.flush();
			socket.close();
		}
		
		
	}
}