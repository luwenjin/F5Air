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
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filters.DropShadowFilter;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.ContextMenu;

	public class VideoNotification extends AbstractNotification
	{
        private var _title:String;
       	private var _videoURL: String = null

       	private var titleLabel:TextField;
       	private var filters:Array;
        private var connection: NetConnection = null;
       	private var stream: NetStream = null;
       	private var video: Video = null;

		public function VideoNotification(title: String, videoURL: String, position: String = null, duration: uint = 5)
		{
			this.filters = [new DropShadowFilter(5, 45, 0x000000, .9)];
			this.videoURL = videoURL;

			super(position, duration);

        	this.title = title;

            this.width = 400;
            this.height = 100;
		}

		override protected function createControls(): void
		{
			super.createControls();
			var cm: ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			// title
            this.titleLabel = new TextField();
            this.titleLabel.autoSize = TextFieldAutoSize.LEFT;
            var titleFormat: TextFormat = titleLabel.defaultTextFormat;
            titleFormat.font = "Verdana";
            titleFormat.bold = true;
            titleFormat.color = 0xFFFFFF;
            titleFormat.size = 10;
			titleFormat.align = TextFormatAlign.LEFT;
            this.titleLabel.defaultTextFormat = titleFormat;
            this.titleLabel.multiline = false;
            this.titleLabel.selectable = false;
            this.titleLabel.wordWrap = false;
            this.titleLabel.contextMenu = cm;
            this.titleLabel.x = 4;
            this.titleLabel.y = 2;
            this.titleLabel.filters = this.filters;
            this.getSprite().addChild(this.titleLabel);

			if (this.videoURL != null)
			{
	            this.connection = new NetConnection();
	            this.connection.addEventListener(NetStatusEvent.NET_STATUS, this.netStatusHandler);
	            this.connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.securityErrorHandler);
	            this.connection.connect(null);
			}
		}

        private function netStatusHandler(event: NetStatusEvent): void 
        {
            switch (event.info.code) 
            {
                case "NetConnection.Connect.Success":
                    this.connectStream();
                    break;
                case "NetStream.Play.StreamNotFound":
                    trace("Unable to locate video: " + this.videoURL);
                    break;
            }
        }

		override protected function beforeClose(): void
		{
			this.video.clear();
			this.stream.close();
			this.connection.close();
			super.beforeClose();
		}

        private function connectStream(): void
        {
            this.stream = new NetStream(this.connection);
            var client:Object = new Object();
            client.onMetaData = function(o: Object): void {};
            this.stream.client = client;
            this.stream.addEventListener(NetStatusEvent.NET_STATUS, this.netStatusHandler);
            this.stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.asyncErrorHandler);
	        this.video = new Video();
            this.video.x = 4;
            this.video.y = 19;
            this.video.filters = this.filters;
            this.video.smoothing = true;
            this.video.attachNetStream(this.stream);
            this.stream.play(this.videoURL);
            this.getSprite().addChild(this.video);
        }

        private function securityErrorHandler(event: SecurityErrorEvent): void
        {
            trace("securityErrorHandler: " + event);
        }

        private function asyncErrorHandler(event: AsyncErrorEvent): void
        {
            // ignore AsyncErrorEvent events.
        }

        public override function set width(width: Number): void
        {
			super.width = width;
			this.titleLabel.width = width - 8;
			this.video.width = width - 8;
        }

		public override function set height(height: Number): void
		{
			super.height = height;
			this.video.height = height - (this.video.y + 4);
		}

        public override function set title(title: String): void
        {
        	this._title = title;
        	this.titleLabel.text = title;
        }

        public override function get title(): String
        {
            return this._title;
        }

		public function get videoURL(): String
		{
			return this._videoURL;
		}

        public function set videoURL(value: String): void
        {
        	this._videoURL = value;
        }
	}
}