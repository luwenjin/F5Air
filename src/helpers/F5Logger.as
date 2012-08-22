package helpers
{
//	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.display.Sprite;
	import flash.utils.getTimer;
	
	import managers.GlobalManager;

	public class F5Logger
	{			
		
		private var name:String;
		private var caller:*;
		
		private var gm:GlobalManager = GlobalManager.instance;
		
		public function F5Logger( caller:*, name:String )
		{
			this.name = '[ '+name+' ]';
			this.caller = caller;
//			this.trace = trace;
		}
		
		public function log( ...rest ):void
		{
			var li:Array = [];
			for each( var obj:Object in rest )
			{
				li.push( obj.toString() );
			}
			
			var message:String = li.join(' ');

			rest.unshift( this.name );
			rest.unshift( getTimer() );
			trace.apply( this, rest );
			
//			MonsterDebugger.trace( this.name, message);
			
			if ( gm.f5 && gm.f5.showStatusBar )
			{
				gm.f5.status = message;
			}
		}
		
		public function track( ...rest ):void
		{
//			MonsterDebugger.log.apply( this.caller, rest );
		}
	}
}