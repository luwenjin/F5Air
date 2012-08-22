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
    import flash.display.Screen;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    
    public class NotificationQueue
    {

        private var queue:Array;
        private var playing:Boolean;
        private var paused:Boolean;
        public var sound: Sound = null;
        private var channel: SoundChannel = null;

        public function NotificationQueue()
        {
            this.queue = new Array();
            this.playing = false;
            this.paused = false;
        }
		
		public function get length():uint
		{
			return this.queue.length;
		}
		
		public function addNotification(notification:AbstractNotification):void
		{
            this.queue.push(notification);
            if (this.queue.length == 1 && !this.playing)
            {
            	this.playing = true;
            	this.run();
            }
		}

		public function clear(): void
		{
			while (this.queue.length > 0)
			{
				var n: AbstractNotification = this.queue.shift() as AbstractNotification;
				n = null;
			}
			if (this.playing)
			{
				this.playing = false;
			}
		}

		public function pause():void
		{
			this.paused = true;
		}

		public function resume():void
		{
			this.paused = false;
			this.run();
		}
        
        private function run(): void
        {
        	if (this.paused || this.queue.length == 0) return;
            var n:AbstractNotification = this.queue.shift() as AbstractNotification;
			var listener:Function = function(e: Event): void
			{
				n.removeEventListener(Event.CLOSE, listener);
				if (sound != null)
				{
					channel.stop();         		
				}
				if (queue.length > 0)
				{
					run();
				}
				else
				{
					playing = false;
				}
			}; 
            n.addEventListener(Event.CLOSE, listener);
            var screen:Screen = Screen.mainScreen;
			switch (n.position)
            {
                case AbstractNotification.TOP_LEFT:
                    n.bounds = new Rectangle(screen.visibleBounds.x + 2, screen.visibleBounds.y + 3, n.width, n.height);
                    break;
                case AbstractNotification.TOP_RIGHT:
                    n.bounds = new Rectangle(screen.visibleBounds.width - (n.width + 2), screen.visibleBounds.y + 3, n.width, n.height);
                    break;
                case AbstractNotification.BOTTOM_LEFT:
                    n.bounds = new Rectangle(screen.visibleBounds.x + 2, screen.visibleBounds.height - (n.height + 2), n.width, n.height);
                    break;
                case AbstractNotification.BOTTOM_RIGHT:
                    n.bounds = new Rectangle(screen.visibleBounds.width - (n.width + 2) , screen.visibleBounds.height - (n.height + 2), n.width, n.height);
                    break;
            }
			n.alwaysInFront = true;
			n.visible = true;
			if (this.sound != null)
			{
				this.channel = this.sound.play();
			}
        }
    }
}
