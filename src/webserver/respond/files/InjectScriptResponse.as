package webserver.respond.files
{
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import helpers.FileType;
	
	import managers.PowerManager;
	
	import webserver.messages.HTTPResponse;

	public class InjectScriptResponse
	{
		
		[Embed(source="assets/js/br.lite.packed.js", mimeType="application/octet-stream")]
		public static const js_lite:Class;
		
		[Embed(source="assets/js/br.full.packed.js", mimeType="application/octet-stream")]
		public static const js_full:Class;
		
		public function InjectScriptResponse()
		{
			
		}
		
		public static function create( path:String='js/br.js' ):HTTPResponse
		{
			var debug:Boolean = false;
			if ( debug )
			{
				var f:File = File.applicationDirectory.resolvePath( 'assets/js/br.js' );;
				return StaticFileResponse.create( f );
			}
			
			var response:HTTPResponse;
			
			var js:ByteArray;
			if ( PowerManager.instance.isFull )
				js = new js_full() as ByteArray;	
			else
				js = new js_lite() as ByteArray;
			
			response = new HTTPResponse();
			response.content_type = FileType.getMimeType( path );
			response.body.writeBytes( js );
			
			return response;
		}
	}
}