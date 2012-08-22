package webserver.respond.files
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import helpers.FileType;
	
	import webserver.messages.HTTPResponse;

	public class HtmlFileResponse
	{
		public function HtmlFileResponse()
		{
			// response files ( only html file type )
		}
		
		public static function create( file:File ):HTTPResponse
		{
			
			var response:HTTPResponse = new HTTPResponse();
			response.content_type = FileType.getMimeType( file.nativePath );
			
			var stream:FileStream = new FileStream();
			stream.open( file, FileMode.READ );
			
			var js:String = '<script src="/con/assets/js/jquery-1.6.3.min.js" type="text/javascript"></script>'
				+ '<script src="/con/assets/js/br.js" type="text/javascript"></script>\n';
			
			stream.position = 0;
			var ba:ByteArray = new ByteArray();
			stream.readBytes(ba);
			stream.close();
			
			var i:int = findHtmlTag( ba );
			
			if ( i>0 )
			{
				response.body.writeBytes( ba, 0, i );
				response.body.writeUTFBytes( js );	
				response.body.writeBytes( ba, i, ba.length-i);
			}
			else
			{
				response.body.writeUTFBytes( js );
				response.body.writeBytes( ba );
			}
			
			return response;
		}
		
		public static function findHtmlTag( ba:ByteArray ):int
		{
			var pos:int;
			var li:Array = [];
			var i:int;
			var start:int;
			
			for( pos=0; pos<ba.length; pos++)
			{
				ba.position = pos;
				i = ba.readByte();
				//				trace(String.fromCharCode(i));
				if ( i == 60 )
				{
					li = [];
					for ( var j:int=0; j<4; j++ ){
						if (ba.bytesAvailable==0) break;
						li.push( ba.readByte() );
					}
					
					if (li.length<4){
						return -1;
					}
					else if (  ( li[0] == 104 || li[0] == 72 ) //h
						&&( li[1] == 116 || li[1] == 84 ) //t
						&&( li[2] == 109 || li[2] == 77 ) //m
						&&( li[3] == 108 || li[3] == 76 ) //l
					){
						return pos
					}
				}
				
			}
			return -1;
		}
	}
}