package managers
{
	import com.adobe.serialization.json.JSON;
	
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import helpers.Base64;

	public class PowerManager extends EventDispatcher
	{
		private static const _instance:PowerManager = new PowerManager();
		
		private var loader:URLLoader;
		
		private var cd:ClientData = ClientData.instance;
		
		
		public function PowerManager()
		{
			if ( _instance != null )
			{
				throw new Error('Please use the instance property to access.');
			}
			loader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, on_loader_COMPLETE );
			loader.addEventListener( IOErrorEvent.IO_ERROR, on_loader_IO_ERROR );
		}
		
		protected function on_loader_IO_ERROR(event:IOErrorEvent):void
		{
			var evt:PowerEvent = new PowerEvent( PowerEvent.ERROR, {'message': '连接激活服务器失败，请重试'} );
			this.dispatchEvent( evt );
		}
		
		protected function on_loader_COMPLETE(event:Event):void
		{
			var b64:String = loader.data as String;
			var ba:ByteArray = Base64.Decode(b64);
			ba.uncompress();
			var s:String = ba.readUTFBytes(ba.bytesAvailable);
			var json:Object = JSON.decode(JSON.decode( s ));
			if ( json.status == 'ok' )
			{
				cd.full_key = json.code;
				cd.powers = json.powers;
				cd.email = json.email;
				cd.save();
				this.dispatchEvent( new PowerEvent( PowerEvent.ACTIVATED, {'powers': json.powers, 'message': json.message } ) );
			}
			else if ( json.status == 'fail' )
			{
				this.dispatchEvent( new PowerEvent( PowerEvent.FAIL, {'message': json.message} ) );
			}
			else
			{
				this.dispatchEvent( new PowerEvent( PowerEvent.ERROR, {'message': '未知错误'} ) );
			}
		}
		
		public static function get instance():PowerManager
		{
			return _instance;
		}
		
		public function get isFull():Boolean
		{
			if ( cd.email && cd.full_key )
			{
				return true;
			}
			return false;
		}
		
		public function activate( email:String, code:String ):void
		{
			var url:String = 'http://api.getf5.com/bactivate';
			
			var req:URLRequest = new URLRequest( url );
			req.method = URLRequestMethod.POST;
			req.contentType = "application/octet-stream";
			
			var items:Object = {};
			items.email = email
			items.code = code
			
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes( JSON.encode( items ) );
			ba.compress();
			req.data = ba;
			
			this.loader.load(req);
		}
	}
}