package webserver.routers
{
	import change.ChangesWatcher;
	
	import flash.filesystem.File;
	
	import mx.binding.utils.ChangeWatcher;
	
	import org.hamcrest.object.nullValue;
	
	import webserver.messages.HTTPRequest;
	import webserver.respond.ChangesResponder;

	public class ApisRouter implements IRouter
	{
		
		public function ApisRouter()
		{
		}
		
		public function get rule():RegExp
		{
			return new RegExp( "/con/changes" );
		}
		
		public function handleRequest( request:HTTPRequest ):void
		{
			new ChangesResponder( request );
		}
		
		public function get rootFolder():File
		{
			return null;
		}
									   
	}
}