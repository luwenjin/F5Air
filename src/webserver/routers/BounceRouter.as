package webserver.routers
{
	import change.ChangesWatcher;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.Socket;
	import flash.utils.getTimer;
	
	import helpers.F5Logger;
	import helpers.UrlParts;
	import helpers.Utils;
	
	import mx.collections.XMLListCollection;
	import mx.logging.Log;
	
	import webserver.WebServer;
	import webserver.messages.HTTPRequest;
	import webserver.respond.BounceResponder;
	
	public class BounceRouter implements IRouter
	{
		private var _rule:RegExp;
		
		public var originHost:String;
		public var originPort:Number;
		
		private var l:F5Logger = new F5Logger( this, 'BounceRouter' );
		private var watcher:ChangesWatcher = ChangesWatcher.instance;
		private var server:WebServer = WebServer.instance;
		
		private var _rootFolder:File;
		
		public var tree:XML = <node label='/' path='/' location="/" isRoot={true} exists={true}></node> ;
		
		public function BounceRouter( originHost:String, originPort:Number )
		{
			this.originHost = originHost;
			this.originPort = originPort;
			
			this.tree.@label = originHost + ':' + originPort;
		}
		
		public function get rootFolder():File
		{
			return _rootFolder;
		}

		public function set rootFolder(value:File):void
		{
			_rootFolder = value;
			updateNode( tree );
		}

		public function get rule():RegExp
		{
			if ( !_rule )
				_rule = new RegExp('/');
			return _rule;
		}
		
		public function addTreeNode( urlParts:UrlParts ):void
		{
			l.log('addTreeNode START');
			var pathParts:Array = urlParts.pathList;
			var li:XMLList;
			var curNode:XML = this.tree;
			var node:XML;
			var current_path_list:Array = [];
			
			for each ( var part:String in pathParts )
			{
				current_path_list.push( part );
				li = curNode.children().(@label==part);
				
				if ( li.length() == 1 )
				{
					curNode = li[0];
				} else {
					var path:String = '/'+current_path_list.join('/');
					node = <node label={part} location={path} path={path}></node>;
					if ( Utils.getExtension( path ) == '' )
					{
						curNode.prependChild( node );
					}
					else
					{
						curNode.appendChild( node );	
					}
					
					curNode = node;
				}
			}
			curNode.@location = urlParts.location;
			l.log('addTreeNode END');
		}
		
		public function getNodeUrl( node:XML ):String
		{
			if ( node.hasOwnProperty( '@location' ) )
				return this.server.rootUrl + UrlParts.ensureRelative( node.@location.toString() );
			else
				return this.server.rootUrl ;
		}
		
		public function handleRequest( request:HTTPRequest ):void
		{
			l.log( 'handleRequest', request.urlParts.pathList );
			this.addTreeNode( request.urlParts );
			new BounceResponder( request, this.originHost, this.originPort );
		}
		
		
		public function updateNode( node:XML ):void
		{
			if( rootFolder ){
				var relativePath:String = UrlParts.ensureRelative( node.@path.toString() );
				
				var f:File = rootFolder.resolvePath( relativePath );
				if ( ! f.exists ){
					node.@exists = false;
					return ;
				}else{
					node.@exists = true;	
				}
				
				if ( f.isDirectory ){
					expandFolderNode( node, f );
					node.@isDir = true;
				}else{
					node.@isDir = false;
				}
			}
			else
			{
				node.@isDir = false;
			}	
		}
		
		public function expandFolderNode( xml:XML, file:File ):void
		{
			var files:Array = file.getDirectoryListing();
			
			for each ( var f:File in files )
			{
				var path:String = UrlParts.ensureAbsolute( server.proxiesRouter.rootFolder.getRelativePath( f ) );
				if ( hasFile( xml.children(), f.name ) ) continue;
				
				var node:XML = <node label={f.name} path={path} location={path} exists={true} isDir={f.isDirectory}></node>;
				if( node.@isDir == true ){
					xml.prependChild( node );	
				}else{
					xml.appendChild( node );
				}
			}
		}
		
		public function hasFile( xl:XMLList, name:String):Boolean
		{
			for each ( var node:XML in xl )
			{
				if ( node.@label == name ) return true;
			}
			return false;
		}
		
		
	}
}