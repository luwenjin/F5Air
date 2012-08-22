package views.components
{
	import flash.display.DisplayObject;
	import flash.filesystem.File;
	import flash.filters.ColorMatrixFilter;
	
	import helpers.FileType;
	
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.core.IFlexDisplayObject;
	
	import org.flexunit.asserts.fail;
	
	import webserver.WebServer;
	import webserver.respond.files.StaticFileResponse;
	
	public class RemoteTreeItemRenderer extends TreeItemRenderer
	{
		
		[Embed(source="assets/images/icon16.png")]
		private var InfoIcon:Class;
		
		private var infoIcon:DisplayObject = DisplayObject( new InfoIcon() ); 
		
		private var server:WebServer = WebServer.instance;
		
		public function RemoteTreeItemRenderer()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
//			if ( ! this.owns( infoIcon ) )
//				this.addChild( infoIcon );
			
//			infoIcon.x = unscaledWidth - 16-5;
//			infoIcon.y = int ( ( unscaledHeight - 16 ) / 2 );
			var xml:XML = this.data as XML;
			
			if ( xml.@isDir == true )
				disclosureIcon.visible = true
			
			if ( xml.@exists == true ){ 
				icon.alpha = 1;
				icon.filters = [];
			}else{
				icon.alpha = 0.5;
				icon.filters = [ greyFilter ];
			}
				
		}
		
		private static var _greyFilter:ColorMatrixFilter;
		public static function get greyFilter():ColorMatrixFilter
		{
			if ( _greyFilter ) return _greyFilter;
			
			var b:Number = 1/3;
			var c:Number = 1 - ( b * 2 );
			var matrix:Array = [c,b,b,0,0,
				b,c,b,0,0,
				b,b,c,0,0,
				0,0,0,1,0];
			_greyFilter = new ColorMatrixFilter( matrix );
			return _greyFilter;
		}
	}
}