package webserver.routers
{
	import flash.filesystem.File;
	
	import webserver.messages.HTTPRequest;

	public interface IRouter
	{
		function get rule():RegExp;
		function handleRequest( request:HTTPRequest ):void;
		function get rootFolder():File;
	}
	
	
}