package helpers
{
	import com.adobe.net.MimeTypeMap;
	
	import flash.filesystem.File;

	public class FileType
	{
		[Embed(source="assets/images/folder.png")]
		public static const FOLDER:Class;
		
		[Embed(source="assets/images/page_world.png")]
		public static const HTML:Class;
		
		[Embed(source="assets/images/page_white_code_red.png")]
		public static const CSS:Class;
		
		[Embed(source="assets/images/page_white_cup.png")]
		public static const JS:Class;
		
		[Embed(source="assets/images/picture.png")]
		public static const IMG:Class;
		
		[Embed(source="assets/images/page_white_flash.png")]
		public static const SWF:Class;
		
		[Embed(source="assets/images/page_white_php.png")]
		public static const PHP:Class;
		
		[Embed(source="assets/images/page_white_visualstudio.png")]
		public static const VS:Class;
		
		[Embed(source="assets/images/world.png")]
		public static const WEB:Class;
		
		[Embed(source="assets/images/page_white.png")]
		public static const DEFAULT:Class;
		
		
		
		public static const mime_map:MimeTypeMap = new MimeTypeMap();
		
		public static const EXT_MAP:Object = {
			'htm': 	HTML,
			'html': HTML,
			'php': PHP,
			'asp': VS,
			'aspx': VS,
			'css': 	CSS,
			'js': 	JS,
			'swf': SWF,
			'png': 	IMG,
			'jpg': 	IMG,
			'jpeg':	IMG,
			'gif': 	IMG,
			'bmp': 	IMG,
			'ico': 	IMG
		}
		
		public static function getFileIcon( file:File ):Class
		{
			if ( file.isDirectory )
				return FOLDER;	
			
			var ext:String = file.extension;
			if ( ext ) 
				ext = ext.toLowerCase();
			else 
				ext = '';
			
			if ( ext && EXT_MAP[ ext ] )
				return EXT_MAP[ ext ];
			
			return DEFAULT;	
		}
		
		public static function getNodeIcon( node:XML ):Class
		{
			if ( node.@icon=='no' ) 
				return null;
			
			if ( node.@isRoot== true) 
				return WEB;
			
			if ( node.@isDir == true )
				return FOLDER;
			
			var ext:String = Utils.getExtension( node.@path );
			if ( ext == '' ){
				return FOLDER; 
			}else if ( ext && EXT_MAP[ ext ] ){
				return EXT_MAP[ ext ];
			}else{
				return DEFAULT;
			}
		}
		
		public static function getMimeType( file_name_or_ext:String ):String
		{
			var mime_type:String;
			var ext:String = Utils.getExtension( file_name_or_ext );
			
			mime_type = mime_map.getMimeType( ext );
			
			if ( mime_type == null )
				mime_type = mime_map.getMimeType('txt');
			
			return mime_type;
		}
		
		public function FileType()
		{
			
		}
	}
}