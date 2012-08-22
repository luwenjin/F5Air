package change.events
{
	import change.WatchResource;
	
	import flash.events.Event;
	
	public class ResourceChangeEvent extends Event
	{
		
		public static const ADD:String = 'ResourceChangeEvent_ADD';
		public static const DEL:String = 'ResourceChangeEvent_DEL';
		public static const CHANGE:String = 'ResourceChangeEvent_CHANGE';
		
		public var resource:WatchResource;
		public var sourceType:String;
		
		public function ResourceChangeEvent(type:String, resource:WatchResource, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.resource = resource;
		}
		
		override public function clone():Event
		{
			var event:ResourceChangeEvent = new ResourceChangeEvent( type, resource, bubbles, cancelable );
			return event;
		}
	}
}