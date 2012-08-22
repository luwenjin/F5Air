package webserver.respond.files
{
	import flash.filesystem.File;
	import flash.net.Socket;
	
	import helpers.FileType;
	
	import webserver.messages.HTTPResponse;

	public class NotFoundResponse
	{
		public function NotFoundResponse( )
		{
		}
		
		public static function create( file:File=null ):HTTPResponse
		{
			var response:HTTPResponse = new HTTPResponse(404);
			response.content_type = FileType.getMimeType( '.html' );
			response.body.writeUTFBytes("<html><body><h1>File Not Found</h1></body></html>");
			
			return response;
		}
	}
}