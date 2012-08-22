package webserver.respond.files
{
	import flash.filesystem.File;
	import flash.net.Socket;
	
	import helpers.FileType;
	import helpers.Utils;
	
	import webserver.messages.HTTPResponse;

	public class FolderResponse
	{
		public function FolderResponse( )
		{
			// list files in folder, return html
		}
		
		public static function create( folder:File, rootFolder:File, path:String ):HTTPResponse
		{
			var li:Array = [
				'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
				'<html>',
				'	<head>',
				'		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />',
				'		<link href="/con/assets/css/style.css" rel="stylesheet" type="text/css"/> ',
				'		<title>' + folder.name +'</title>',
				'	</head>',
				'	<body>',
				'		<h1>' + folder.nativePath +'</h1>', 
				'		<ul>'
			];
			
			if( folder.nativePath != rootFolder.nativePath )
			{
				
				li.push(
					'			<li class="parent">',
					'				<a href="/' + encodeURI(rootFolder.getRelativePath( folder.parent )) +'">(返回上一级)</a>',
					'			</li>'
				)
			}
			
			var file_list:Array = [];
			var f:File;
			for each ( f in folder.getDirectoryListing())
			{
				if ( f.isHidden )
					continue; 
				if(f.isDirectory)
				{
					file_list.unshift( f );
				}
				else
				{
					file_list.push( f );
				}
			}
			
			for each ( f in file_list )
			{
				var style_name:String;
				if ( f.isDirectory )
				{
					style_name = 'dir';
				}
				else
				{
					style_name = f.extension ? f.extension.replace('.', '').toLowerCase():'no';
				}
				li.push( 
					'			<li class="'+style_name+'">',
					'				<a href="'+Utils.joinPaths(path, encodeURI(rootFolder.getRelativePath( f )))+'">' + f.name + '</a>',
					'			</li>'
				);
			}
			li.push(
				'		</ul>',
				'	</body>',
				'</html>'
			);
			
			var response:HTTPResponse = new HTTPResponse();
			response.content_type = FileType.getMimeType( '.html' );
			response.body.writeUTFBytes( li.join('\n') );
			return response;
		}
	}
}