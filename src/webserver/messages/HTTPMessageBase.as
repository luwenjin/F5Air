package webserver.messages
{
	import com.adobe.utils.StringUtil;
	
	import flash.utils.ByteArray;

	public class HTTPMessageBase
	{
		
		public var headers:Object = {};
		public var body:ByteArray;
		
		public function HTTPMessageBase()
		{
		}
		
		public function getHeader( key:String ):String
		{
			for ( var s:String in this.headers ){
				if ( s.toLowerCase() == key.toLowerCase() ) 
					return this.headers[s];
			}
			return null;
		}
		
		public function setHeader( key:String, val:String ):void
		{
			var low_key:String = key.toLowerCase();
			for ( var k:String in this.headers ){
				if ( k.toLowerCase() == low_key ) 
					delete this.headers[k]
			}
			if ( val == null ) return;
			this.headers[key] = val;
		}
		
		public static function findHeadEnd( bytes:ByteArray ):uint
		{
			var crlfCount:int = 0;
			var byte:uint;
			bytes.position = 0;
			
			while ( bytes.bytesAvailable > 0 )
			{
				byte = bytes.readByte();
				if ( byte == 10 || byte == 13 )
					crlfCount += 1;
				else
					crlfCount = 0;
				if ( crlfCount == 4 ) break;
			}
			
			return bytes.position;
		}
		
		public static function parseHeaders( lines:Array ):Object
		{
			var items:Array;
			var key:String;
			var val:String;
			var result:Object = {};
			for each ( var line:String in lines )
			{
				line = StringUtil.trim( line );
				if ( line.length == 0 ) continue;
				
				items = line.split(':');
				if ( items.length <= 1 )
				{
					key = line;
					val = '';
				}
				else
				{
					key = StringUtil.trim( items.shift() );
					val = StringUtil.trim( items.join(':') );
				}
				result[key] = val;
			}
			return result;
			
		}
	}
}