package managers
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import helpers.Base64;
	
	import mx.collections.ArrayCollection;
	import mx.utils.Base64Encoder;

	public class StatManager
	{
		private static const _instance:StatManager = new StatManager();
		
		private var loader:URLLoader;
		
		private var requests:ArrayCollection = new ArrayCollection();
		private var current_request:URLRequest;
		private var requesting:Boolean = false;
		
		private var timer:Timer;
		
		private var gm:GlobalManager = GlobalManager.instance;
		private var cd:ClientData = ClientData.instance;
		
		public function StatManager()
		{
			if ( _instance != null )
			{
				throw new Error('Please use the instance property to access.');
			}
			
			this.loader = new URLLoader();
			this.loader.addEventListener(Event.COMPLETE, on_loader_COMPLETE);
			this.loader.addEventListener(IOErrorEvent.IO_ERROR, on_loader_ERROR);
			
			//todo: offline log
			
			this.timer = new Timer(5*60*1000);
			this.timer.addEventListener(TimerEvent.TIMER, on_TIMER);
			this.timer.start(); 

			this.log( 'F5Client', 'launch', {
				ver: gm.appVer,
				os: gm.os,
				screens: gm.screens,
				bounds: [cd.x, cd.y, cd.w, cd.y],
				full_key: cd.full_key,
				email: cd.email,
				networks: cd.networks
			})
		}
		
		protected function on_TIMER(event:TimerEvent=null):void
		{
			this.log( 'F5Client', 'ping');
		}
		
		protected function on_loader_ERROR(event:IOErrorEvent):void
		{
			this.requesting = false;
			this.send_logs();
		}
		
		protected function on_loader_COMPLETE(event:Event):void
		{
			this.requesting = false;
			this.send_logs();
			
		}
		
		public static function get instance():StatManager
		{
			return _instance;
		}
		
		public function log( category:String, key:String, items:Object=null ):void
		{
			var req:URLRequest = new URLRequest('http://api.getf5.com/blog');
			req.method = URLRequestMethod.POST;
			req.contentType = "application/octet-stream";
			
			if ( items == null ) items = {};
			items.client_id = cd.id;
			items.category = category;
			items.key = key;
			
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes( JSON.encode( items ) );
			ba.compress();
			req.data = ba;
			
			this.requests.addItem(req);
			this.send_logs();
		}
		
		private function send_logs():void
		{
			if (this.requests.length>0 && !this.requesting){
				this.requesting = true;
				var req:URLRequest = this.requests.removeItemAt(0) as URLRequest;
				this.loader.load( req );
			}
		}
	}
}