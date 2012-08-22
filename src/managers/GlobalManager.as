package managers
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	
	import helpers.UUID;
	
	import mx.core.Window;
	import mx.core.WindowedApplication;

	public class GlobalManager
	{
		private static const _instance:GlobalManager = new GlobalManager();
		
		public var f5:F5;
		
		public var appVer:String;
		
		public var os:String;
		public var screens:Array = [];
		
		public var lang:String = 'cn';
		
		public var mainWin:NativeWindow = null;
		public var backWin:NativeWindow = null;
		
		private var cd:ClientData = ClientData.instance;
		
		public function GlobalManager()
		{
			if ( _instance != null )
			{
				throw new Error('Please use the instance property to access.');
			}
			
			//test
//			cd.full_key = null;
			
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			this.appVer = appXml.ns::versionNumber;
			
			this.os = Capabilities.os;
			
			
			var screen_obj:Object;
			for each ( var s:Screen in Screen.screens ){
				screen_obj = {
					width: s.bounds.width,
					height: s.bounds.height
				};
				this.screens.push(screen_obj);
			}

		}

		public static function get instance():GlobalManager
		{
			return _instance;
		}
		
	}
}