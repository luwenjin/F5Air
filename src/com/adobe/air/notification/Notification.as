/*
    Adobe Systems Incorporated(r) Source Code License Agreement
    Copyright(c) 2005 Adobe Systems Incorporated. All rights reserved.
    
    Please read this Source Code License Agreement carefully before using
    the source code.
    
    Adobe Systems Incorporated grants to you a perpetual, worldwide, non-exclusive, 
    no-charge, royalty-free, irrevocable copyright license, to reproduce,
    prepare derivative works of, publicly display, publicly perform, and
    distribute this source code and such derivative works in source or 
    object code form without any attribution requirements.  
    
    The name "Adobe Systems Incorporated" must not be used to endorse or promote products
    derived from the source code without prior written permission.
    
    You agree to indemnify, hold harmless and defend Adobe Systems Incorporated from and
    against any loss, damage, claims or lawsuits, including attorney's 
    fees that arise or result from your use or distribution of the source 
    code.
    
    THIS SOURCE CODE IS PROVIDED "AS IS" AND "WITH ALL FAULTS", WITHOUT 
    ANY TECHNICAL SUPPORT OR ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING,
    BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  ALSO, THERE IS NO WARRANTY OF 
    NON-INFRINGEMENT, TITLE OR QUIET ENJOYMENT.  IN NO EVENT SHALL ADOBE 
    OR ITS SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
    OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
    OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOURCE CODE, EVEN IF
    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package com.adobe.air.notification
{           
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.filters.DropShadowFilter;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.ui.ContextMenu;
	
    public class Notification
        extends AbstractNotification
    {        
        private var _message:String;        
        private var _title:String;
       	private var _bitmap: Bitmap;

        private var messageLabel:TextField;
       	private var titleLabel:TextField;
       	private var filters:Array;

        public function Notification(title:String, message:String, position:String = null, duration:uint = 5, bitmap: Bitmap = null)
        {
			if (bitmap != null)
			{
    	    	this.bitmap = bitmap;
   			}

			this.filters = [new DropShadowFilter(5, 45, 0x000000, .9)];

            super(position, duration);

        	this.title = title;
        	this.message = message;

            this.width = 300;
            this.height = 50;
	    }

		private const Left_Pos: int = 56;

		override protected function createControls():void
		{
			super.createControls();
			var leftPos: int = (this.bitmap != null) ? 56 : 2;
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			
			// title
            this.titleLabel = new TextField();
            this.titleLabel.autoSize = TextFieldAutoSize.LEFT;
            var titleFormat:TextFormat = this.titleLabel.defaultTextFormat;
            titleFormat.font = "simsun"; //vernada
            titleFormat.bold = true;
            titleFormat.color = 0xFFFFFF;
            titleFormat.size = 12; //10
			titleFormat.align = TextFormatAlign.LEFT;
            this.titleLabel.defaultTextFormat = titleFormat;
            this.titleLabel.multiline = false;
            this.titleLabel.selectable = false;
            this.titleLabel.wordWrap = false;
            this.titleLabel.contextMenu = cm;
            this.titleLabel.x = leftPos+3;
            this.titleLabel.y = 2+3;
            this.titleLabel.filters = this.filters;
            this.getSprite().addChild(this.titleLabel);

			// message            
            this.messageLabel = new TextField();
			this.messageLabel.autoSize = TextFieldAutoSize.NONE;
            var messageFormat:TextFormat = this.messageLabel.defaultTextFormat;
            messageFormat.font = "simsum"; //vernada
            messageFormat.color = 0xFFFFFF;
            messageFormat.size = 12; //10
			messageFormat.align = TextFormatAlign.LEFT;
            this.messageLabel.defaultTextFormat = messageFormat;
            this.messageLabel.multiline = true;
            this.messageLabel.selectable = false;
            this.messageLabel.wordWrap = true;
            this.messageLabel.contextMenu = cm;
            this.messageLabel.x = leftPos+3;
            this.messageLabel.y = 19+6;
            this.messageLabel.filters = this.filters;
            this.getSprite().addChild(this.messageLabel);

			if (this.bitmap != null)
			{
				var posX: int = 2;
				var posY: int = 2;
				var scaleX: Number = 1;
				var scaleY: Number = 1;
	            var bitmapData:BitmapData = this.bitmap.bitmapData;
	            if (bitmapData.width > 50 || bitmapData.height > 100)
	            {
	            	var __x: int = bitmapData.width - 50;
	            	var __y: int = bitmapData.height - 100;
            		scaleX = (__x > __y) ? 50 / bitmapData.width : 100 / bitmapData.height;
	            	scaleY = scaleX;
	            	posX = 27 - ((bitmapData.width * scaleX) / 2);
	            	posY = 52 - ((bitmapData.height * scaleY) / 2);
	            }
	            else
	            {
		            posX = 27 - (bitmapData.width / 2);
		            posY = 52 - (bitmapData.height / 2);					
	            }
	            this.bitmap.scaleX = scaleX;
	            this.bitmap.scaleY = scaleY;
	            this.bitmap.x = posX;
	            this.bitmap.y = posY;
	            this.bitmap.filters = this.filters;
	            this.getSprite().addChild(this.bitmap);
			}
		}

		public function set bitmap(bitmap:Bitmap):void
		{
			this._bitmap = new Bitmap(bitmap.bitmapData);
	    	this._bitmap.smoothing = true;
		}
		
		public function get bitmap():Bitmap
		{
			return this._bitmap;
		}

        public override function set title(title:String):void
        {
        	this._title = title;
        	this.titleLabel.text = title;
        }

        public override function get title():String
        {
            return this._title;
        }

        public function set message(message:String):void
        {
        	this._message = message;
           	this.messageLabel.text = message;
        }                                

		public function set htmlText(htmlText:String):void
		{
			this.messageLabel.htmlText = htmlText;			
		}		

		public function get htmlText():String
		{
			return this.messageLabel.htmlText; 
		}

        public function get message():String
        {
            return this._message;
        }

        public override function set width(width:Number):void
        {
			super.width = width;
			this.messageLabel.width = width - (this.messageLabel.x + 4);
			this.titleLabel.width = width - 8;
        }

        public override function set height(height:Number):void
        {
			super.height = height;
			this.messageLabel.height = height - (this.messageLabel.y + 4);
        }
                
    }
}