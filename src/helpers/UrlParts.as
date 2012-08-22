package helpers
{
	import webserver.respond.files.StaticFileResponse;

	public class UrlParts
	{
		public var scheme:String;
		public var host:String;
		public var port:Number;
		public var path:String;
		public var args:Object;
		
		public function UrlParts( scheme:String, host:String, port:Number, absPath:String, args:Object=null)
		{
			this.scheme = scheme;
			this.host = host;
			this.port = port;
			this.path = decodeURI(absPath);
			
			if ( args == null ) args = {};
			this.args = args;
		}
		
		public function get location():String
		{
			//later part of url
			return encodeURI( path ) + argstring;
		}
		
//		public function get pathWithArgs():String
//		{
//			return this.path + this.argstring;
//		}
		
		public function get pathList():Array
		{
			var li:Array = this.path.split(/\/+/);
			if ( li.length > 0 && li[0] == '' )
				li.shift();
			if ( li.length > 0 && li[li.length-1] == '' )
				li.pop();
			return li;
		}
		
		public function get argstring():String
		{
			var li:Array = [];
			
			for ( var key:String in this.args )
			{
				var val:String = this.args[key];
				if ( val )
				{
					li.push( key + '=' + encodeURIComponent( val ) );
				}
				else
				{
					li.push( key + '=' );
				}
			}
			
			if ( li.length == 0 ) 
				return '';
			else
				return '?' + li.join('&')
		}
		
		public function get url():String
		{
			return this.scheme+'://'+ location;
		}
		
		public static function parseAndCreate( url:String ):UrlParts
		{
			var li:Array;
			
			li = url.split('://');
			var scheme:String = ( li.shift() as String ).toLowerCase();
			
			li = ( li.shift() as String ).split('/');
			var _host_port:String = li.shift() as String;
			var host:String;
			var port:Number;
			if ( _host_port.indexOf(':')>-1 )
			{
				host = ( _host_port.split(':')[0] as String ).toLowerCase();
				port = Number( _host_port.split(':')[1] );
			}
			else if ( _host_port == '' )
			{
				host = null;
				port = 80;
			}
			else
			{
				host = _host_port;
				if ( scheme == 'https')
					port = 443;
				else
					port = 80;
			}
			var path_args_obj:Object = splitPathArgs( "/"+li.join('/') );
			var path:String = path_args_obj['path'];
			var args:Object = path_args_obj['args'];
			return new UrlParts( scheme, host, port, path, args );
		}
		
		public static function splitPathArgs( path_args:String ):Object
		{
			var path_args_li:Array = path_args.split('?');
			
			var path:String = decodeURI( path_args_li.shift() as String );
			var args:Object = {};
			
			if ( path_args_li.length != 0 )
			{
				var key_val_list:Array = ( path_args_li.shift() as String ).split('&');
				var key_val:Array;
				var key:String;
				var val:String;

				for each(var key_val_string:String in key_val_list)
				{
					key_val = key_val_string.split('=');
					key = key_val[0];
					if(key_val.length>1)
					{
						val = decodeURIComponent( key_val[1] );
					}
					else
					{
						val = null;
					}
					args[key] = val;
				}
			}
			
			
			return {
				path: path,
				args: args
			};
		}
		
		public static function ensureRelative( path:String ):String
		{
			var r:RegExp = new RegExp( '/*' );
			return  path.replace( r, '' );
		}
		
		public static function ensureAbsolute( path:String ):String
		{
			if ( path.charAt(0) != '/' ) path = '/' + path;
			return path;
		}
	}
}