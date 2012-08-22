/*
*	A Base64 encoder/decoder implementation in Actionscript 3
*	This work is made available under http://creativecommons.org/licenses/by-nc-sa/2.0/de/deed.en
*
*	@author subhero@gmail.com
*	@version 0.5
*/
package helpers {
	// import ->
	import flash.utils.ByteArray;
	import flash.errors.EOFError;
	// <- import
	
	// Base64 ->
	/*
	*	A class used for transforming a ByteArray to a Base64-encoded string and vice versa.
	*	Since the "built-in" class (mx.utils.Base64Encoder) is not documented yet, this class can be  
	*	used for Base64 encoding/decoding in the meantime. 
	*	The class will be deprecated as soon as Macromedia/Adobe decides to fully release the 
	*	"native" AS3 Base64 class (Flex2 full release respectively). 
	*	Its implementation is based upon a HowTo {@link http://www.kbcafe.com/articles/HowTo.Base64.pdf}, 
	*	a Java implementation {@link http://ostermiller.org/utils/Base64.java.html} and an 
	*	AS2-implementation by Jason Nussbaum {@link http://blog.jasonnussbaum.com/?p=108}
	*
	*/
	public class Base64 {
		// mx.utils.StringUtil
		public static function isWhitespace(char:String):Boolean{
            switch (char){
                case " ":
                case "\t":
                case "\r":
                case "\n":
                case "\f":
                    return true;    
                default:
                    return false;
            }
        }
		
		// the Base64 "alphabet"
		private static var _b64Chars:Array=new Array(
			'A','B','C','D','E','F','G','H',
			'I','J','K','L','M','N','O','P',
			'Q','R','S','T','U','V','W','X',
			'Y','Z','a','b','c','d','e','f',
			'g','h','i','j','k','l','m','n',
			'o','p','q','r','s','t','u','v',
			'w','x','y','z','0','1','2','3',
			'4','5','6','7','8','9','+','/'
		)
		// the reverse-lookup object used for decoding
		private static var _b64Lookup:Object=_buildB64Lookup();
		// the boolean to insert linebreaks after 76 chars into the Base64 encoded string
		private static var _linebreaks:Boolean;
		
		/*
		*	The class method for encoding an array of bytes to a Base64 encoded string. 
		*
		*	@param bArr A ByteArray containing values to encode
		*	@param linebreaks A boolean to insert a linebreak after 76 Base64-chars
		*	@return The Base64 encoded string
		*	
		*/
		public static function Encode(bArr:ByteArray, linebreaks:Boolean=false):String
		{
			_linebreaks= linebreaks;
			return _encodeBytes(bArr);
		}
		
		/*
		*	The class method for decoding a Base64 encoded string to an array of bytes. 
		*
		*	@param str A Base64 encoded string
		*	@return An array of bytes
		*	
		*/
		public static function Decode(str:String):ByteArray
		{
			return _decodeSring(str);
		}
		
		/*
		*	The private helper class method to build an object used for reverse B64 char lookup. 
		*
		*	@return An object with each B64 char as a property containing the corresponding value
		*	
		*/
		private static function _buildB64Lookup():Object
		{
			var obj:Object=new Object();
			for (var i:Number=0; i < _b64Chars.length; i++)
			{
				obj[_b64Chars[i]]=i;
			} 
			return obj;
		}
		
		/*
		*	The private helper class method to determine whether a given char is B64 compliant. 
		*
		*	@param char A character as string (length=1)
		*	@return A boolean indicating the given char *is* in the B64 alphabet
		*	
		*/
		private static function _isBase64(char:String):Boolean
		{
			return _b64Lookup[char] != undefined;
		}
		
		/*
		*	The private class method for encoding an array of bytes into a B64 encoded string. 
		*
		*	@param bs An array of bytes
		*	@return The B64 encoded string
		*
		*	@see formatter.Base64.Encode()
		*	
		*/
		private static function _encodeBytes(bs:ByteArray):String
		{
			var b64EncStr:String = "";
			var bufferSize:uint;
			var col:uint=0;
			bs.position=0;
			while (bs.position < bs.length)
			{
				bufferSize= bs.bytesAvailable >= 3 ? 3 : bs.bytesAvailable;
				var byteBuffer:ByteArray=new ByteArray();
				bs.readBytes(byteBuffer, 0, bufferSize);
				b64EncStr += _b64EncodeBuffer(byteBuffer);
				col+=4;
				if (_linebreaks && col%76 == 0) {
					b64EncStr += "\n";
					col=0;
				}
			}
			return b64EncStr.toString();
		}
		
		/*
		*	The private class method for encoding a buffer of 3 bytes (24bit) to 4 B64-chars 
		*	(representing 6bit each => 24bit). 
		*
		*	@param buffer An array of bytes (1 <= length <= 3)
		*	@return The byte buffer encoded to 4 B64 chars as string
		*
		*	@see formatter.Base64._encodeBytes()
		*	
		*/
		private static function _b64EncodeBuffer(buffer:ByteArray):String
		{
			var bufferEncStr:String = "";
			bufferEncStr += _b64Chars[buffer[0] >> 2];
			switch (buffer.length)
			{
				case 1 :
					bufferEncStr += _b64Chars[((buffer[0] << 4) & 0x30)];
					bufferEncStr += "=="; 
					break;
				case 2 : 
					bufferEncStr += _b64Chars[(buffer[0] << 4) & 0x30 | buffer[1] >> 4];
					bufferEncStr += _b64Chars[(buffer[1] << 2) & 0x3c];
					bufferEncStr += "=";
					break;
				case 3 : 
					bufferEncStr += _b64Chars[(buffer[0] << 4) & 0x30 | buffer[1] >> 4];
					bufferEncStr += _b64Chars[(buffer[1] << 2) & 0x3c | buffer[2] >> 6];
					bufferEncStr += _b64Chars[buffer[2] & 0x3F];
					break;
				default : 	trace("Base64 byteBuffer outOfRange");	
			}			
			return bufferEncStr.toString();
		} 
		
		/*
		*	The private class method for decoding a string containing B64 chars to an array of bytes 
		*
		*	@param s The B64 encoded string
		*	@return A decoded array of bytes
		*
		*	@see formatter.Base64.Decode()
		*	
		*/
		private static function _decodeSring(s:String):ByteArray
		{
			var b64EncString:String="" + s;
			var b64DecBytes:ByteArray=new ByteArray();
			var stringBuffer:String="";
			var lgth:uint=b64EncString.length;		
			for (var i:uint=0; i < lgth; i++)
			{
				var char:String=b64EncString.charAt(i);
				if (!isWhitespace(char) && (_isBase64(char) || char == "=")) {
					stringBuffer += char;
					if (stringBuffer.length == 4) {
						b64DecBytes.writeBytes( _b64DecodeBuffer(stringBuffer) ); 
						stringBuffer="";
					}
				}
			}
			b64DecBytes.position=0;
			return b64DecBytes;
		}
		
		/*
		*	The private class method for decoding a string buffer of 4 B64 chars 
		*	(each representing 6bit) to an array of 3 bytes. 
		*
		*	@param buffer A string containing B64 chars (length = 4)
		*	@return An array of bytes containing the decoded values
		*
		*	@see formatter.Base64._decodeBytes()
		*	
		*/
		private static function _b64DecodeBuffer(buffer:String):ByteArray
		{
			var bufferEncBytes:ByteArray=new ByteArray();
			var charValue1:uint=_b64Lookup[buffer.charAt(0)];
			var charValue2:uint=_b64Lookup[buffer.charAt(1)];
			var charValue3:uint=_b64Lookup[buffer.charAt(2)];
			var charValue4:uint=_b64Lookup[buffer.charAt(3)];
			bufferEncBytes.writeByte(charValue1 << 2 | charValue2 >> 4);
			if (buffer.charAt(2) != "=") bufferEncBytes.writeByte(charValue2 << 4 | charValue3 >> 2);
			if (buffer.charAt(3) != "=") bufferEncBytes.writeByte(charValue3 << 6 | charValue4);
			return bufferEncBytes;
		}	
	}
	// <- Base64
}