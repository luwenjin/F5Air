package managers
{
	import spark.components.Group;
	
	import views.dialogs.AuthorizeDialog;
	import views.dialogs.DropDialog;
	
	import webserver.respond.files.StaticFileResponse;

	public class DialogManager
	{
		private static const _instance:DialogManager = new DialogManager();
		
		private var _dropDialog:DropDialog;
		private var _authorizeDialog:AuthorizeDialog; 
		
		public var layer:Group;
		
		public function DialogManager()
		{
			if ( _instance != null )
			{
				throw new Error('Please use the instance property to access.');
			}
		}
		
		public static function get instance():DialogManager
		{
			return _instance;
		}
		
		public function get dropDialog():DropDialog
		{
			if ( ! _dropDialog ){
				_dropDialog = new DropDialog();
				_dropDialog.layer = layer;
			}
			return _dropDialog;
		}
		
		public function get authorizeDialog():AuthorizeDialog
		{
			if ( ! _authorizeDialog ){
				_authorizeDialog = new AuthorizeDialog();
				_authorizeDialog.layer = layer;
			}
			return _authorizeDialog;
		}
		
		
	}
}