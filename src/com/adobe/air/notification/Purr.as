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
	import flash.desktop.DockIcon;
	import flash.desktop.InteractiveIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.Bitmap;
	import flash.display.NativeMenu;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.media.Sound;

	public class Purr
	{
		private var topLeftQ:NotificationQueue;
		private var topRightQ:NotificationQueue;
		private var bottomLeftQ:NotificationQueue;
		private var bottomRightQ:NotificationQueue;
		private var paused:Boolean;

		public function Purr(idleThreshold:int = -1)
		{
			this.topLeftQ = new NotificationQueue();
			this.topRightQ = new NotificationQueue();
			this.bottomLeftQ = new NotificationQueue();
			this.bottomRightQ = new NotificationQueue();

			this.paused = false;
			
			if (idleThreshold == -1) idleThreshold = 10;
			
			NativeApplication.nativeApplication.idleThreshold = idleThreshold * 60;
			NativeApplication.nativeApplication.addEventListener(Event.USER_IDLE, function(e: Event): void { pause(); });
			NativeApplication.nativeApplication.addEventListener(Event.USER_PRESENT, function(e: Event): void { resume(); });
		}

		public function alert(alertType:String, nativeWindow:NativeWindow):void
		{
			if (NativeApplication.supportsDockIcon)
			{
				DockIcon(NativeApplication.nativeApplication.icon).bounce(alertType);
			}
			else if (NativeApplication.supportsSystemTrayIcon)
			{
				if (nativeWindow != null)
				{
					nativeWindow.notifyUser(alertType);
				}
			}
		}

		public function setIdleThreshold(idle:int):void
		{
			NativeApplication.nativeApplication.idleThreshold = idle * 60;
		}
		
		public function addNotification(n:AbstractNotification):void
		{
			switch (n.position)
            {
                case AbstractNotification.TOP_LEFT:
                    this.topLeftQ.addNotification(n);
                    break;
                case AbstractNotification.TOP_RIGHT:
                    this.topRightQ.addNotification(n);
                    break;
                case AbstractNotification.BOTTOM_LEFT:
                    this.bottomLeftQ.addNotification(n);
                    break;
                case AbstractNotification.BOTTOM_RIGHT:
                    this.bottomRightQ.addNotification(n);
                    break;
            }			
		}

		public function addTextNotificationByParams(title:String, message:String, position:String = null, duration:uint = 5, bitmap:Bitmap = null):Notification
		{
			var n:Notification = new Notification(title, message, position, duration, bitmap);
			this.addNotification(n);
            return n;
		}

		public function setMenu(menu:NativeMenu): void
		{
			if (NativeApplication.supportsDockIcon)
			{
				DockIcon(NativeApplication.nativeApplication.icon).menu = menu;
			}
			else if (NativeApplication.supportsSystemTrayIcon)
			{
				SystemTrayIcon(NativeApplication.nativeApplication.icon).menu = menu;
			}
		}

		public function getMenu():NativeMenu
		{
			if (NativeApplication.supportsDockIcon)
			{
				return DockIcon(NativeApplication.nativeApplication.icon).menu;
			}
			else if (NativeApplication.supportsSystemTrayIcon)
			{
				return SystemTrayIcon(NativeApplication.nativeApplication.icon).menu;
			}
			return null;
		}

		public function setIcons(icons:Array, tooltip:String = null):void
		{
			if (NativeApplication.nativeApplication.icon is InteractiveIcon)
			{
				InteractiveIcon(NativeApplication.nativeApplication.icon).bitmaps = icons;
			}
			if (NativeApplication.supportsSystemTrayIcon)
			{
				SystemTrayIcon(NativeApplication.nativeApplication.icon).tooltip = tooltip;
			}
		}

		public function getIcons():Array
		{
			if (NativeApplication.nativeApplication.icon is InteractiveIcon)
			{
				return InteractiveIcon(NativeApplication.nativeApplication.icon).bitmaps;
			}
			return null;
		}

		public function getToolTip():String
		{
			if (NativeApplication.supportsSystemTrayIcon)
			{
				return SystemTrayIcon(NativeApplication.nativeApplication.icon).tooltip;
			}
			return null;
		}

		public function clear(where: String = null): void
		{
			switch (where)
			{
                case AbstractNotification.TOP_LEFT || null:
					this.topLeftQ.clear();
                case AbstractNotification.TOP_RIGHT || null:
					this.topRightQ.clear();
                case AbstractNotification.BOTTOM_LEFT || null:
					this.bottomLeftQ.clear();
                case AbstractNotification.BOTTOM_RIGHT || null:
					this.bottomRightQ.clear();
			}
		}

		public function pause():void
		{
			this.topLeftQ.pause();
			this.topRightQ.pause();
			this.bottomLeftQ.pause();
			this.bottomRightQ.pause();
			this.paused = true;
		}

		public function resume():void
		{
			this.topLeftQ.resume();
			this.topRightQ.resume();
			this.bottomLeftQ.resume();
			this.bottomRightQ.resume();
			this.paused = false;
		}

		public function set notificationSound(value: Sound): void
		{
			this.topLeftQ.sound = value;
			this.topRightQ.sound = value;
			this.bottomLeftQ.sound = value;
			this.bottomRightQ.sound = value;
		}

		public function get notificationSound(): Sound
		{
			return this.topLeftQ.sound;
		}

		public function isPaused():Boolean
		{
			return this.paused;
		}
		
		public function get length():uint
		{
			return (this.topLeftQ.length + this.topRightQ.length + this.bottomLeftQ.length + this.bottomRightQ.length);
		}
	}
}