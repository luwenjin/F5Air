package webserver.routers
{
	import change.ChangesWatcher;
	import change.WatchResource;
	
	import flash.filesystem.File;
	import flash.utils.getTimer;
	
	import helpers.F5Logger;
	import helpers.FileType;
	import helpers.Utils;
	
	import webserver.WebServer;
	import webserver.messages.HTTPRequest;
	import webserver.messages.HTTPResponse;
	import webserver.respond.files.FolderResponse;
	import webserver.respond.files.HtmlFileResponse;
	import webserver.respond.files.NotFoundResponse;
	import webserver.respond.files.StaticFileResponse;

	public class FilesRouter implements IRouter
	{
		
		private var path:String;
		private var source:File;
		
		private var _rule:RegExp;
		
		private var watcher:ChangesWatcher = ChangesWatcher.instance;
		private var server:WebServer = WebServer.instance;
		
		private var l:F5Logger = new F5Logger(this, 'FilesRouter');
		
		public function FilesRouter( source:File, path:String="/" )
		{	
			if ( path.substr(0, 1) != '/' ) 
				throw Error('rootPath must starts with "/"' );
			
			this.path = path;
			this.source = source;
		}
		
		public function get rule():RegExp
		{
			if ( !_rule )
				_rule = new RegExp( path );
			return _rule;
		}
		
		public function handleRequest( request:HTTPRequest ):void
		{
			l.log( 'START HandleRequest', getTimer() );
			this.handleWatching( request );
			
			var file_rel_path:String = decodeURI(request.path).replace( this.path, '' );
			if ( file_rel_path.charAt(0) == '/' ) file_rel_path = file_rel_path.substr(1);
			var file:File = this.source.resolvePath( file_rel_path );
			
			var response:HTTPResponse;
			if ( file.exists == false )
			{
				response = NotFoundResponse.create( file );
			} 
			else if ( file.isDirectory )
			{
				response = FolderResponse.create( file, this.source, this.path );
			}
			else // is file
			{
				if ( FileType.getMimeType(file.nativePath) == FileType.getMimeType( '.html' ) )
					response = HtmlFileResponse.create( file )
				else
					response = StaticFileResponse.create( file );
			}
			response.setHeader( 'Pragma', 'no-cache' );
			response.send( request.socket );
			l.log( 'END HandleRequest', getTimer() );
		}
		
		private function handleWatching( request:HTTPRequest):void
		{
			var file_rel_path:String = request.path.replace( this.path, '' );
			if ( file_rel_path.charAt(0) == '/' ) file_rel_path = file_rel_path.substr(1);
			var file:File = this.source.resolvePath( file_rel_path );
			
			if ( !file.isDirectory && request.method=='GET' )
			{
				var referer:String = request.getHeader('Referer');
				this.watcher.add( request.url, file, referer );
				
				if ( file.extension && FileType.getMimeType( file.nativePath ) == FileType.getMimeType('.html') )
				{
					this.watcher.add( request.url, file, request.url );	
				}
				
				if ( file.extension 
					&& file.extension.toLowerCase() == 'css' 
					&& referer
					&& Utils.getExtension( referer ).toLowerCase() == 'css')
				{
					var resource:WatchResource = watcher.getResource( referer );
					
					for each ( var ref:String in resource.referers )
						this.watcher.add( request.url, file, ref);
				}
			}
		}
		
		public function getFileUrl( file:File ):String
		{
			var raw_url:String = this.server.rootUrl + this.rootFolder.getRelativePath( file );
			var encoded_url:String = encodeURI(raw_url);
			return encoded_url;	
		}
		
		public function get rootFolder():File
		{
			return this.source;
		}
		
		
	}
}