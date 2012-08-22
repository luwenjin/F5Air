package webserver.respond
{
	import change.ChangesWatcher;
	import change.WatchResource;
	import change.events.ResourceChangeEvent;
	
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.Timer;
	
	import helpers.FileType;
	
	import webserver.messages.HTTPRequest;
	import webserver.messages.HTTPResponse;

	public class ChangesResponder
	{
		private var watcher:ChangesWatcher = ChangesWatcher.instance;
		private var request:HTTPRequest;
		
		private var referer:String;
		private var userLastChangeTime:Number;
		
		private var timer:Timer;
		
		public function ChangesResponder( request:HTTPRequest )
		{
			this.request = request;
			referer = request.headers['Referer'];
			
			try
			{
				userLastChangeTime = Number( request.args['t'] );	
			}
			catch(error:Error)
			{
				this.userLastChangeTime = 0;
			}
			
			this.checkAndGo();
		}
		
		protected function checkAndGo():void
		{
			var changes:Array = watcher.getChanges( userLastChangeTime, referer );
			if ( changes.length > 0 )
			{
				var change_list:Array = [];
				for each (var resource:WatchResource in changes)
				{
					change_list.push( resource.url );
				}
				this.sendResponseAndCloseSocket( watcher.lastChangeTime, change_list );
			}
			else
			{
				timer = new Timer( 20*1000, 1 );
				timer.addEventListener( TimerEvent.TIMER_COMPLETE, on_TIMER_COMPLETE );
				timer.start();
				
				watcher.addEventListener( ResourceChangeEvent.CHANGE, onResourceChange );	
				request.socket.addEventListener(Event.CLOSE, on_socket_CLOSE);
			}
			
		}
		
		protected function cleanUp():void
		{
			if( timer ) {
				timer.removeEventListener( TimerEvent.TIMER_COMPLETE, on_TIMER_COMPLETE );
				if( timer.running ) timer.stop();
			}
			if ( watcher )
				watcher.removeEventListener( ResourceChangeEvent.CHANGE, onResourceChange );
			if ( request && request.socket )
				request.socket.removeEventListener(Event.CLOSE, on_socket_CLOSE);
		}
		
		protected function onResourceChange(event:ResourceChangeEvent):void
		{
			var resource:WatchResource = event.resource
			if ( ( resource.referers.indexOf( referer ) >= 0 || resource.referers.indexOf( encodeURI(this.referer)) >=0 ) 
				&& resource.lastChangeTime > userLastChangeTime )
			{
				sendResponseAndCloseSocket( resource.lastChangeTime, [ resource.url ] );
			}
			
		}
		
		protected function on_TIMER_COMPLETE(event:TimerEvent):void
		{
			this.sendResponseAndCloseSocket( watcher.lastChangeTime, [] );
		}
		
		private function sendResponseAndCloseSocket( _lastUserChangeTime:Number, change_list:Array ):void
		{
			for (var i:int=0; i<change_list.length; i++)
				change_list[i] = decodeURI(change_list[i]);
			
			var result:Object = {
				t: _lastUserChangeTime,
				changes: change_list
			};
			
			var json:String = JSON.encode( result ) ;
			trace( 'send_response', json );
			
			var response:HTTPResponse = new HTTPResponse(200);
			response.content_type = FileType.getMimeType( '.json' );
			response.body.writeUTFBytes( json );
			
			try{
				response.send( this.request.socket );	
			}
			catch(error:Error)
			{
				trace( 'send_response failed' );
			}
			this.cleanUp();
		}
		
		protected function on_socket_CLOSE(event:Event):void
		{
			trace('client disconnected');
		}
		
	}
}