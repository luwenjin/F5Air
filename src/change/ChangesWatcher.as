package change
{
	import change.events.ResourceChangeEvent;
	
	import com.adobe.air.filesystem.FileMonitor;
	import com.demonsters.debugger.MonsterDebugger;
	
	import consts.Setting;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import helpers.F5Logger;
	
	import mx.collections.ArrayCollection;
	
	import webserver.messages.HTTPRequest;
	
	
	[Event(name="CHANGE", type="change.events.ResourceChangeEvent")]
	public class ChangesWatcher extends EventDispatcher
	{
		public var lastChangeTime:Number = WatchResource.AFTER_INIT_TIME;
			
		private var resourceMap:Object;
		private var resourceCount:int = 0;
		
		private var detectTimer:Timer;
		
		private var pauseTimer:Timer;
		private var pausing:Boolean = false;
		
		// hot pages
		private var hotUrlMap:Object = {};
		private var coolDownTime:Number = 40*1000;

		private var l:F5Logger;
		
		private static const _instance:ChangesWatcher = new ChangesWatcher();
		
		public function ChangesWatcher()
		{
			if ( _instance != null )
			{
				throw new Error('Please use the instance property to access.');
			}
			
			this.resourceMap = {};
			this.detectTimer = new Timer( 70, 0 ); 
			this.detectTimer.addEventListener( TimerEvent.TIMER, on_detectTimer_TIMER );
			
			l = new F5Logger( this, 'ChangesWatcher' );
		}
		
		public static function get instance():ChangesWatcher
		{
			return _instance;
		}
		
		public function start():void
		{
			if ( !running ) 
				this.detectTimer.start();
		}
		
		public function stop():void
		{
			if ( running )
				this.detectTimer.stop();
		}
		
		public function pause( time:int = 300 ):void
		{
			if ( ! pauseTimer )
			{
				pauseTimer = new Timer(time, 1);
				pauseTimer.addEventListener( TimerEvent.TIMER_COMPLETE, on_pauseTimer_COMPLETE );
			}
			else
			{
				pauseTimer.delay = time;
			}
			this.pausing = true;
			pauseTimer.start();
			l.log( 'pause', time );
		}
		
		private function on_pauseTimer_COMPLETE( event:TimerEvent ):void
		{
			this.pausing = false;
		}
		
		public function clear():void
		{
			this.resourceMap = {};
			this.resourceCount = 0;
		}
		
		public function getChanges( t:Number, referer:String ):Array
		{
			if ( t >= this.lastChangeTime )
			{
				return [];
			}
			else
			{
				var changes:Array = [];
				var resource:WatchResource;
				for (var url:String in this.resourceMap )
				{
					resource = this.resourceMap[ url ] as WatchResource;
					if ( resource.lastChangeTime > t )
					{
						changes.push( resource );
					}
				}
				return changes;
			}
		}
		
		public function get running():Boolean
		{
			return detectTimer.running;
		}
		
		public function add( url:String, source:*, referer:String=null, request:HTTPRequest=null ):void
		{
			var resource:WatchResource = resourceMap[ url ];
			
			if ( ! resource )
			{
				l.log( 'add watch', url );
				resource = new WatchResource( url );
				resourceMap[ url ] = resource;
				resourceCount += 1;
			}
			if ( !referer ) referer = url ;
			resource.addReferer( referer );
			if ( source as File ){
				resource.sourceFile = source;
			}else if ( source as String ){
				resource.sourceUrl = source;
				if ( request && request.getHeader('Cookie') ){
					resource.lastCookie = request.getHeader( 'Cookie' );
				}
			}
				
//			if ( resource.lastChangeTime > lastChangeTime )
//				lastChangeTime = resource.lastChangeTime;
		}
		
		
//		public function touch(url:String):void
//		{
//			hotUrlMap[url] = (new Date()).getTime();
//		}
//		
//		public function maintainHotUrlMap():void
//		{
//			var time:Number = (new Date()).getTime();
//			for ( var url:String in hotUrlMap ){
//				if ( time - hotUrlMap[url] > coolDownTime ){
//					delete hotUrlMap[url];
//				}else{
//					trace( url, hotUrlMap[url] );
//				}
//			}
//		}

		
		public function detectChanges():void
		{
//			maintainHotUrlMap();
			for each ( var resource:WatchResource in resourceMap ){
				resource.detectChange();
			}
		}
		
		public function reportChange( changeType:String, resource:WatchResource ):void
		{
			if ( resource.lastChangeTime > lastChangeTime )
				lastChangeTime = resource.lastChangeTime;

			var event:ResourceChangeEvent = new ResourceChangeEvent( changeType, resource );
			this.dispatchEvent( event );	
			
			l.log( 'reportChange', event.type, resource.url );
			MonsterDebugger.log( 'reportChange', event.type, resource.url );
		}

		public function getResource( url:String ):WatchResource
		{
			return resourceMap[ url ];
		}
		
		protected function on_detectTimer_TIMER(event:TimerEvent):void
		{
			if ( ! pausing ) 
				this.detectChanges();
			
			if ( running ) 
				this.detectTimer.start();
		}
	}
}