package managers
{
	import flash.events.Event;

	public class PowerEvent extends Event
	{
		public static const ACTIVATED:String = 'activated';
		public static const ERROR:String = 'error';
		public static const FAIL:String = 'fail';
		
		public var data:Object;
		
		public function PowerEvent(type:String, data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		override public function clone():Event
		{
			var event:PowerEvent = new PowerEvent( this.type, this.data, this.bubbles, this.cancelable );
			return event;
		}
	}
}