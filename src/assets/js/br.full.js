(function(){

    function trace(){};

    var $ = jQuery.noConflict();
    
    function get_ext(file_path){
        var i = file_path.lastIndexOf('.');
        var ext;
        if ( i >= 0){
            ext = file_path.substring( i, file_path.length );
            var j = ext.lastIndexOf('?');
            if ( j>= 0 ){
                ext = ext.substring(0,j);
            }
            return ext.toLowerCase();
        }
        return null;
    }
    function stripUrl( url ){
        var i = url.indexOf('?');
        if ( i < 0 ){
            i = url.indexOf('#');
        }
        if ( i < 0 ){
            return url;
        }else{
            return url.substring(0,i);
        }
    }

    var path = {

			// This scary looking regular expression parses an absolute URL or its relative
			// variants (protocol, site, document, query, and hash), into the various
			// components (protocol, host, path, query, fragment, etc that make up the
			// URL as well as some other commonly used sub-parts. When used with RegExp.exec()
			// or String.match, it parses the URL into a results array that looks like this:
			//
			//     [0]: http://jblas:password@mycompany.com:8080/mail/inbox?msg=1234&type=unread#msg-content
			//     [1]: http://jblas:password@mycompany.com:8080/mail/inbox?msg=1234&type=unread
			//     [2]: http://jblas:password@mycompany.com:8080/mail/inbox
			//     [3]: http://jblas:password@mycompany.com:8080
			//     [4]: http:
			//     [5]: jblas:password@mycompany.com:8080
			//     [6]: jblas:password
			//     [7]: jblas
			//     [8]: password
			//     [9]: mycompany.com:8080
			//    [10]: mycompany.com
			//    [11]: 8080
			//    [12]: /mail/inbox
			//    [13]: /mail/
			//    [14]: inbox
			//    [15]: ?msg=1234&type=unread
			//    [16]: #msg-content
			//
			urlParseRE: /^(((([^:\/#\?]+:)?(?:\/\/((?:(([^:@\/#\?]+)(?:\:([^:@\/#\?]+))?)@)?(([^:\/#\?]+)(?:\:([0-9]+))?))?)?)?((\/?(?:[^\/\?#]+\/+)*)([^\?#]*)))?(\?[^#]+)?)(#.*)?/,

			//Parse a URL into a structure that allows easy access to
			//all of the URL components by name.
			parseUrl: function( url ) {
				// If we're passed an object, we'll assume that it is
				// a parsed url object and just return it back to the caller.
				if ( $.type( url ) === "object" ) {
					return url;
				}

				var u = url || "",
					matches = path.urlParseRE.exec( url ),
					results;
				if ( matches ) {
					// Create an object that allows the caller to access the sub-matches
					// by name. Note that IE returns an empty string instead of undefined,
					// like all other browsers do, so we normalize everything so its consistent
					// no matter what browser we're running on.
					results = {
						href:         matches[0] || "",
						hrefNoHash:   matches[1] || "",
						hrefNoSearch: matches[2] || "",
						domain:       matches[3] || "",
						protocol:     matches[4] || "",
						authority:    matches[5] || "",
						username:     matches[7] || "",
						password:     matches[8] || "",
						host:         matches[9] || "",
						hostname:     matches[10] || "",
						port:         matches[11] || "",
						pathname:     matches[12] || "",
						directory:    matches[13] || "",
						filename:     matches[14] || "",
						search:       matches[15] || "",
						hash:         matches[16] || ""
					};
				}
				return results || {};
			},

			//Turn relPath into an asbolute path. absPath is
			//an optional absolute path which describes what
			//relPath is relative to.
			makePathAbsolute: function( relPath, absPath ) {
				if ( relPath && relPath.charAt( 0 ) === "/" ) {
					return relPath;
				}

				relPath = relPath || "";
				absPath = absPath ? absPath.replace( /^\/|(\/[^\/]*|[^\/]+)$/g, "" ) : "";

				var absStack = absPath ? absPath.split( "/" ) : [],
					relStack = relPath.split( "/" );
				for ( var i = 0; i < relStack.length; i++ ) {
					var d = relStack[ i ];
					switch ( d ) {
						case ".":
							break;
						case "..":
							if ( absStack.length ) {
								absStack.pop();
							}
							break;
						default:
							absStack.push( d );
							break;
					}
				}
				return "/" + absStack.join( "/" );
			},

			//Returns true if both urls have the same domain.
			isSameDomain: function( absUrl1, absUrl2 ) {
				return path.parseUrl( absUrl1 ).domain === path.parseUrl( absUrl2 ).domain;
			},

			//Returns true for any relative variant.
			isRelativeUrl: function( url ) {
				// All relative Url variants have one thing in common, no protocol.
				return path.parseUrl( url ).protocol === "";
			},

			//Returns true for an absolute url.
			isAbsoluteUrl: function( url ) {
				return path.parseUrl( url ).protocol !== "";
			},

			//Turn the specified realtive URL into an absolute one. This function
			//can handle all relative variants (protocol, site, document, query, fragment).
			makeUrlAbsolute: function( relUrl, absUrl ) {
				if ( !path.isRelativeUrl( relUrl ) ) {
					return relUrl;
				}

				var relObj = path.parseUrl( relUrl ),
					absObj = path.parseUrl( absUrl ),
					protocol = relObj.protocol || absObj.protocol,
					authority = relObj.authority || absObj.authority,
					hasPath = relObj.pathname !== "",
					pathname = path.makePathAbsolute( relObj.pathname || absObj.filename, absObj.pathname ),
					search = relObj.search || ( !hasPath && absObj.search ) || "",
					hash = relObj.hash;

				return protocol + "//" + authority + pathname + search + hash;
			},

			//Add search (aka query) params to the specified url.
			addSearchParams: function( url, params ) {
				var u = path.parseUrl( url ),
					p = ( typeof params === "object" ) ? $.param( params ) : params,
					s = u.search || "?";
				return u.hrefNoSearch + s + ( s.charAt( s.length - 1 ) !== "?" ? "&" : "" ) + p + ( u.hash || "" );
			},

			convertUrlToDataUrl: function( absUrl ) {
				var u = path.parseUrl( absUrl );
				if ( path.isEmbeddedPage( u ) ) {
				    // For embedded pages, remove the dialog hash key as in getFilePath(),
				    // otherwise the Data Url won't match the id of the embedded Page.
					return u.hash.split( dialogHashKey )[0].replace( /^#/, "" );
				} else if ( path.isSameDomain( u, documentBase ) ) {
					return u.hrefNoHash.replace( documentBase.domain, "" );
				}
				return absUrl;
			},

			//get path from current hash, or from a file path
			get: function( newPath ) {
				if( newPath === undefined ) {
					newPath = location.hash;
				}
				return path.stripHash( newPath ).replace( /[^\/]*\.[^\/*]+$/, '' );
			},

			//return the substring of a filepath before the sub-page key, for making a server request
			getFilePath: function( path ) {
				var splitkey = '&' + $.mobile.subPageUrlKey;
				return path && path.split( splitkey )[0].split( dialogHashKey )[0];
			},

			//set location hash to path
			set: function( path ) {
				location.hash = path;
			},

			//test if a given url (string) is a path
			//NOTE might be exceptionally naive
			isPath: function( url ) {
				return ( /\// ).test( url );
			},

			//return a url path with the window's location protocol/hostname/pathname removed
			clean: function( url ) {
				return url.replace( documentBase.domain, "" );
			},

			//just return the url without an initial #
			stripHash: function( url ) {
				return url.replace( /^#/, "" );
			},

			//remove the preceding hash, any query params, and dialog notations
			cleanHash: function( hash ) {
				return path.stripHash( hash.replace( /\?.*$/, "" ).replace( dialogHashKey, "" ) );
			},

			//check whether a url is referencing the same domain, or an external domain or different protocol
			//could be mailto, etc
			isExternal: function( url ) {
				var u = path.parseUrl( url );
				return u.protocol && u.domain !== documentUrl.domain ? true : false;
			},

			hasProtocol: function( url ) {
				return ( /^(:?\w+:)/ ).test( url );
			},

			isEmbeddedPage: function( url ) {
				var u = path.parseUrl( url );

				//if the path is absolute, then we need to compare the url against
				//both the documentUrl and the documentBase. The main reason for this
				//is that links embedded within external documents will refer to the
				//application document, whereas links embedded within the application
				//document will be resolved against the document base.
				if ( u.protocol !== "" ) {
					return ( u.hash && ( u.hrefNoHash === documentUrl.hrefNoHash || ( documentBaseDiffers && u.hrefNoHash === documentBase.hrefNoHash ) ) );
				}
				return (/^#/).test( u.href );
			}
		};



	jQuery.cookie = function (key, value, options) {

        // key and at least value given, set cookie...
        if (arguments.length > 1 && String(value) !== "[object Object]") {
            options = jQuery.extend({}, options);

            if (value === null || value === undefined) {
                options.expires = -1;
            }

            if (typeof options.expires === 'number') {
                var days = options.expires, t = options.expires = new Date();
                t.setDate(t.getDate() + days);
            }

            value = String(value);

            return (document.cookie = [
                encodeURIComponent(key), '=',
                options.raw ? value : encodeURIComponent(value),
                options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
                options.path ? '; path=' + options.path : '',
                options.domain ? '; domain=' + options.domain : '',
                options.secure ? '; secure' : ''
            ].join(''));
        }

        // key and possibly options given, get cookie...
        options = value || {};
        var result, decode = options.raw ? function (s) { return s; } : decodeURIComponent;
        return (result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie)) ? decode(result[1]) : null;
    };


    
    var F5 = {
        init: 1,
        last_modify: 0,

        start: function (){
            F5.restoreScrollPosition();
            F5.check();
        },

        restoreScrollPosition: function(){
            var y = $.cookie('__F5ScrollY');
            if ( y == null ) return;
            $.cookie('__F5ScrollY', null);
            if (window.pageYOffset!=null) window.pageYOffset = y;
            if (document.documentElement.scrollTop!=null) document.documentElement.scrollTop = y;
            if (window.pageYOffset!=null) window.pageYOffset = y;
            if ( document.body.scrollTop!=null ) document.body.scrollTop = y
        },
        
        check: function() {
            var args = { 't': F5.last_modify, 'ts': Math.random()};
            $.ajax({
                type: 'GET',
                url: '/con/changes',
                data: args,
                dataType: 'json',
                success: function(data){
                    F5.on_data(data);
                }
            });
        },

        on_data: function (data){
            F5.last_modify = data.t;
            trace( (new Date()).getTime(),' init=', F5.init, ' t=', data.t, ' ', data.changes);
            if ( F5.init )
            {
                F5.init = 0;
            }
            else if (data.changes.length>0)
            {
                F5.handle_changes(data.changes);
            }
            setTimeout(F5.check, 200);
        },

        handle_changes: function(changes){
            var path, ext;
            for (var i=0; i<changes.length; i++){
                path = changes[i];
                ext = get_ext(path);
                trace(ext);
                if ( ext == '.css' ){
                    F5.update_css( path )
                }
                else if ( ext=='.less' ){
                    F5.update_less( path );
                }
                else{
                    F5.refresh();
                }
            }

        },

        refresh: function (){
            var y = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
            $.cookie('__F5ScrollY', y);
            location.reload();
        },

        update_css: function ( url ){
            url = stripUrl(url);
            var local_url;
            var found = false;
            $('link').each( function( idx, el ){
                local_url = path.makeUrlAbsolute( el.href, location.href );
                if (local_url.indexOf( url ) == 0)
                {
                    el.href = url + '?' + Math.random();
                    found = true;
                    return;
                }
            });
            if ( ! found ) F5.refresh();
        },

        update_less: function ( url ){
            if ( window.less && window.less.refresh ){
                url = stripUrl(url);
                var local_url;
                var found = false;
                $('link').each( function( idx, el ){
                    local_url = path.makeUrlAbsolute( el.href, location.href );
                    if (local_url.indexOf( url ) == 0)
                    {
                        el.href = url + '?' + Math.random();
                    }
                });
                window.less.refresh();
            }else{
                F5.refresh();
            }
        }
    };

    function bind_onload(){
        if ( !window.F5loaded ){
            $(window).bind('load', F5.start);
            window.F5loaded = true;
            if ( window.f5debug ) trace = function(){ console.log.apply( console, arguments ) };

        }
    }
    $(document).bind('ready', bind_onload);
    $(window).bind('load', bind_onload);
})();


