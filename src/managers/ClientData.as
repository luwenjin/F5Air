package managers
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.net.SharedObject;
	
	import helpers.UUID;
	
	import org.hamcrest.object.nullValue;

	public class ClientData
	{
		
		private var so:SharedObject;
		
		private static const _instance:ClientData = new ClientData();
		
		public function ClientData()
		{
			if ( _instance != null )
			{
				throw new Error('Please use the instance property to access.');
			}
			this.so = SharedObject.getLocal('f5');
		}
		
		public static function get instance():ClientData
		{
			return _instance;
		}
		
		
		public function save():void
		{
			so.flush();
		}
		
		
		public function get id():String
		{
			if ( ! so.data['client_id'] )
			{
				so.data['client_id'] = (new UUID()).toString();
				this.save();
			}
			return so.data['client_id']
		}
		
		
		public function get full_key():String
		{
			return so.data['full_key'];
		}
		public function set full_key( code:String ):void
		{
			so.data['full_key'] = code;
		}
		
		
		public function get powers():Object
		{
			if ( so.data['powers'] == null)
				so.data['powers'] = {};
			
			return so.data['powers'];
		}
		public function set powers( obj:Object ):void
		{
			so.data['powers'] = obj;
		}
		
		
		public function get email():String
		{
			return so.data['email'] as String;
		}
		public function set email( s:String ):void
		{
			so.data['email'] = s;
		}
		
		
		public function get lastProjectNativePath():String
		{
			return so.data['projects.latest.nativePath'] as String;
		}
		public function set lastProjectNativePath( s:String ):void
		{
			so.data['projects.latest.nativePath'] = s;
		}
		
		
		public function get x():int
		{
			if ( so.data['win.x'] == null )
			{
				so.data['win.x'] = 600;
			}
			return so.data['win.x'];
		}
		public function set x( n:int ):void
		{
			so.data['win.x'] = n;
		}
		
		
		public function get y():int
		{
			if ( so.data['win.y'] == null)
			{
				so.data['win.y'] = 100;
			}
			return so.data['win.y'];
		}
		public function set y( n:int ):void
		{
			so.data['win.y'] = n;
		}
		
		
		public function get w():int
		{
			if ( so.data['win.w'] == null )
			{
				so.data['win.w'] = 250;
			}
			return so.data['win.w'];
		}
		public function set w( n:int ):void
		{
			so.data['win.w'] = n;
		}
		
		
		public function get h():int
		{
			if ( so.data['win.h'] == null )
			{
				so.data['win.h'] = 500;
			}
			return so.data['win.h'];
		}
		public function set h( n:int ):void
		{
			so.data['win.h'] = n;
		}
		
		
		public function get alwaysInFront():Boolean
		{
			if ( so.data['win.alwaysInFront'] == null )
			{
				so.data['win.alwaysInFront'] = false;
			}
			return so.data['win.alwaysInFront'];
		}
		public function set alwaysInFront( val:Boolean ):void
		{
			so.data['win.alwaysInFront'] = val;
		}
		
		
		public function get networks():Array
		{
			var result:Array = [];
			var ni:NetworkInfo = NetworkInfo.networkInfo;
			var interfaceVector:Vector.<NetworkInterface> = ni.findInterfaces();
			for each ( var item:NetworkInterface in interfaceVector )
			{
				result.push({
					MAC: item.hardwareAddress,
					active: item.active
				})
			}
			return result;
		}
		
		public function get hint_HOW_TO_USE_isKnown():Boolean
		{
			if ( so.data['hints.HOW_TO_USE.isKnown'] == true )
			{
				return true;
			}
			return false;
		}
		public function set hint_HOW_TO_USE_isKnown( b:Boolean ):void
		{
			so.data['hints.HOW_TO_USE.isKnown'] = b;
		}
		
		public function get lastFolderSelected( ):File
		{
			var nativePath:String = so.data['pref.lastFolderSelected'] as String;
			if ( nativePath ) return new File( nativePath );
			return new File();
		}
		
		public function set lastFolderSelected( f:File ):void
		{
			if ( f ) so.data['pref.lastFolderSelected'] = f.nativePath;
		}
		
		public function readProjectsXML():XML
		{
			var f:File = File.documentsDirectory.resolvePath('F5/projects.xml');
			if ( ! f.exists ) return null;
			
			var fs:FileStream = new FileStream();
			fs.open( f, FileMode.READ );
			var xml:XML = XML( fs.readUTFBytes( fs.bytesAvailable ) );
			fs.close();
			return xml;
		}
		
		public function writeProjectsXML( xml:XML ):void
		{
			var f:File = new File( File.documentsDirectory.resolvePath('F5/projects.xml').nativePath );
			var fs:FileStream = new FileStream();
			fs.open( f, FileMode.WRITE );
			fs.writeUTFBytes( xml.toXMLString() );
			fs.close();
		}
	}
}