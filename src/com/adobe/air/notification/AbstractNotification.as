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
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	[Event(name=NotificationClickedEvent.NOTIFICATION_CLICKED_EVENT, type="com.adobe.air.notification.NotificationClickedEvent")]

	public class AbstractNotification 
		extends NativeWindow
	{
        public static const TOP_LEFT:String = "topLeft";
        public static const TOP_RIGHT:String = "topRight";
        public static const BOTTOM_LEFT:String = "bottomLeft";
        public static const BOTTOM_RIGHT:String = "bottomRight";

        private var _duration:uint;
        private var _id:String;
        private var _position:String;

       	private var closeTimer:Timer;
       	private var alphaTimer:Timer;
		private var sprite:Sprite;

		public function AbstractNotification(position:String = null, duration:uint = 5)
		{
			super(this.getWinOptions());

			this.createControls();

            this.visible = false;

        	if (position == null)
        	{
	            if (NativeApplication.supportsDockIcon)
	            {
	            	position = AbstractNotification.TOP_RIGHT;
	            }
	            else if (NativeApplication.supportsSystemTrayIcon)
	            {
	            	position = AbstractNotification.BOTTOM_RIGHT;
	            }
        	}
        	this.position = position;
            this.duration = duration;
		}

		protected function getWinOptions(): NativeWindowInitOptions
		{
            var result: NativeWindowInitOptions = new NativeWindowInitOptions();
            result.maximizable = false;
            result.minimizable = false;
            result.resizable = false;
            result.transparent = true;
            result.systemChrome = NativeWindowSystemChrome.NONE;
            result.type = NativeWindowType.LIGHTWEIGHT;
            return result;
		}

		protected function getSprite(): Sprite
		{
			if (this.sprite == null)
			{
				this.sprite = new Sprite();
				this.sprite.alpha = 0;
				this.stage.addChild(this.sprite);
				this.sprite.addEventListener(MouseEvent.CLICK, this.notificationClick);
			}
			return this.sprite;
		}

		protected function createControls():void
		{
			this.bounds = new Rectangle(100, 100, 800, 600);
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
		}

		protected function beforeClose(): void
		{
			// do custom process.
			// see videoNotificaton class for more specific usecase.		
		}

		private function superClose():void
		{
			this.beforeClose();
			super.close();
		}

		override public function close(): void
		{
	        if (this.closeTimer != null)
	        {
	            this.closeTimer.stop();
	            this.closeTimer = null;
	        }

			if (this.alphaTimer != null)
			{
				this.alphaTimer.stop();
				this.alphaTimer = null;
			}

			this.alphaTimer = new Timer(25);
			var listener:Function = function (e:TimerEvent):void
			{
				alphaTimer.stop();
				var nAlpha:Number = getSprite().alpha;
				nAlpha = nAlpha - .04;
				getSprite().alpha = nAlpha;
				if (getSprite().alpha <= 0)
				{
					alphaTimer.removeEventListener(TimerEvent.TIMER, listener);
					superClose();
				}
				else 
				{
					alphaTimer.start();
				}
			};
			this.alphaTimer.addEventListener(TimerEvent.TIMER, listener);
			this.alphaTimer.start();
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if (value == true)
			{
				this.alphaTimer = new Timer(10);
				var listener:Function = function (e:TimerEvent):void
				{
					alphaTimer.stop();
					var nAlpha:Number = getSprite().alpha;
					nAlpha = nAlpha + .04;
					getSprite().alpha = nAlpha;
					if (getSprite().alpha < .9)
					{
						alphaTimer.start();
					}
					else
					{
						alphaTimer.removeEventListener(TimerEvent.TIMER, listener);
						startClose();
					}
				};
				this.alphaTimer.addEventListener(TimerEvent.TIMER, listener);
				this.alphaTimer.start();
			}
		}

		private function startClose():void
		{
			this.closeTimer = new Timer(duration * 1000);
			var listener:Function = function(e:TimerEvent):void
			{
				closeTimer.removeEventListener(TimerEvent.TIMER, listener);
				close();
			};
			this.closeTimer.addEventListener(TimerEvent.TIMER, listener); 
			this.closeTimer.start();
		}
		
        public function set position(position:String):void
        {
        	this._position = position;
        }

        public function get position():String
        {
            return this._position;
        }

        public function get id():String
        {
        	return this._id;
        }

        public function set id(id:String):void
        {
        	this._id = id;
        }

        public function set duration(duration:uint):void
        {
           this._duration = duration;
        }

        public function get duration():uint
        {
            return this._duration;
        }

		private function drawBackGround(): void
		{
			this.getSprite().graphics.clear();
            this.getSprite().graphics.beginFill(0x333333);
            this.getSprite().graphics.drawRoundRect(0, 0, this.width, this.height, 5, 5); //30,30
            this.getSprite().graphics.endFill();
		}

        public override function set width(width:Number):void
        {
			super.width = width;
			this.drawBackGround()
        }

        public override function set height(height:Number):void
        {
			super.height = height;
			this.drawBackGround()
        }

		private function notificationClick(event:MouseEvent):void
		{
			var sprite:Sprite = event.currentTarget as Sprite;
			sprite.removeEventListener(MouseEvent.CLICK, this.notificationClick);
			this.dispatchEvent(new NotificationClickedEvent());
			this.close();
		}
	}
}