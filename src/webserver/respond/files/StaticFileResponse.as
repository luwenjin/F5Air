package webserver.respond.files
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.Socket;
	
	import helpers.FileType;
	
	import webserver.messages.HTTPResponse;

	public class StaticFileResponse
	{	
		public function StaticFileResponse( )
		{
			// response files ( except html file type )
		}
		
		public static function create( file:File ):HTTPResponse
		{
			var response:HTTPResponse = new HTTPResponse();
			response.content_type = FileType.getMimeType( file.nativePath );
			response.connection = 'close';
			
			var stream:FileStream = new FileStream();
			stream.open( file, FileMode.READ );
			
			stream.readBytes( response.body, response.body.length );
			stream.close();	
			
			return response;
		}
	}
}