package webserver.events
{
	import flash.events.Event;
	
	import webserver.routers.IRouter;
	
	public class RouterEvent extends Event
	{
		public static const ADD:String = 'RouterEvent_ADD';
		public static const REMOVE:String = 'RouterEvent_REMOVE';
		
		public var router:IRouter;
		
		public function RouterEvent(type:String, router:IRouter, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.router = router;
		}
		
		override public function clone():Event
		{
			return new RouterEvent( this.type, this.router, this.bubbles, this.cancelable );
		}
	}
}