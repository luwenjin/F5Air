package webserver.messages
{
	import com.adobe.utils.StringUtil;
	
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import helpers.UrlParts;

	public class HTTPRequest extends HTTPMessageBase
	{
		public var url:String;
		public var urlParts:UrlParts;
		public var ver:String;
		public var method:String;
		public var path:String;
		public var args:Object;
		
		public var socket:Socket;
		
		private var _raw:String;
		
		public function HTTPRequest( socket:Socket )
		{
			this.socket = socket;
			this.read();
		}
		
		public function get raw():String
		{
			return this._raw
		}
		
		private function read():void
		{
			var bytes:ByteArray = new ByteArray();
			socket.readBytes( bytes );			
			var raw_content:String = ''+ bytes;

			this.loads( raw_content );
		}
		
		public function get relative_path():String
		{
			return this.path.substring(1);
		}
		
		public function loads( raw_content:String ):void
		{
			this._raw = raw_content;
			var lines:Array = raw_content.split('\r\n');
			
			parseStartLine( lines.shift() );
			headers = parseHeaders( lines );
			
			var encoded_path:String;
			encoded_path = encodeURI( this.path );
			
			this.url = 'http://'+ this.headers['Host']+ encoded_path;
			this.urlParts = UrlParts.parseAndCreate( this.url );
		}
		
		private function parseStartLine( s:String ):void
		{
			var items:Array = s.split(' ');
			
			this.method = ( items[0] as String ).toUpperCase();
			
			var path_args_obj:Object = UrlParts.splitPathArgs( items[1] );
			this.path = path_args_obj['path'];
			this.args = path_args_obj['args'];
			this.ver = items[2];
		}
		
		
	}
}