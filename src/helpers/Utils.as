package helpers
{

	public class Utils
	{
		public function Utils()
		{
		}
		
		public static function validateEmail(email:String):Boolean
		{
			var re:RegExp = new RegExp(/(?:^|\s)[-a-z0-9_\.]+@(?:[-a-z0-9]+\.)+[a-z]{2,6}(?:\s|$)/i);
			return re.test(email);
		}
		
		public static function getExtension( path_or_filename:String ):String
		{
			var idx:int = path_or_filename.lastIndexOf( '/' );
			if ( idx > -1 )
				path_or_filename = path_or_filename.substring( idx+1 );
			
			idx = path_or_filename.lastIndexOf( '.' );
			var ext:String;
			
			if ( idx > -1 )
				ext = path_or_filename.substring( idx+1 ).toLowerCase();
			else
				ext = '';
			
			return ext;
			
		}
		
		public static function joinPaths( p1:String, p2:String ):String
		{
			if ( p2.charAt(0) == '/' ) return p2;
			if ( p1.charAt( p1.length-1 ) != '/' ) p1 += '/';
			
			var p:String = p1 + p2;
			p = p.replace( /\/+/g, '/' );
			return p;
		}
		
		public static function parseDate( s:String ):Date
		{
			/*
			Sun, 06 Nov 1994 08:49:37 GMT    ; RFC 822, updated by RFC 1123
			Sunday, 06-Nov-94 08:49:37 GMT   ; RFC 850, obsoleted by RFC 1036
			Sun Nov  6 08:49:37 1994         ; ANSI C's asctime() format
			*/
			return new Date();
		}
	}
}