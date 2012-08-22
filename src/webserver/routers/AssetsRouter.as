package webserver.routers
{
	import flash.filesystem.File;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import helpers.FileType;
	
	import managers.PowerManager;
	
	import webserver.messages.HTTPRequest;
	import webserver.messages.HTTPResponse;
	import webserver.respond.files.InjectScriptResponse;
	import webserver.respond.files.NotFoundResponse;
	import webserver.respond.files.StaticFileResponse;

	public class AssetsRouter implements IRouter
	{
		private var _rule:RegExp;
		
		public function AssetsRouter( )
		{
		}
		
		public function get rule():RegExp
		{
			return new RegExp( '/con/assets' );
		}
		
		public function handleRequest( request:HTTPRequest ):void
		{
			var response:HTTPResponse;
			
			var relative_path:String = request.path.replace( '/con/assets/', '');
			
			if ( relative_path == 'js/br.js' )
			{
				response = InjectScriptResponse.create();
			}
			else
			{
				var asset_file:File = File.applicationDirectory.resolvePath( 'assets/'+relative_path );
				if ( asset_file.exists )
					response = StaticFileResponse.create( asset_file );
				else
					response = NotFoundResponse.create( asset_file );	
			}
			
			response.send( request.socket );
		}
		
		public function get rootFolder():File
		{
			return null;
		}
	}
}