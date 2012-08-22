(function(){

	function trace(){};
	
    var $ = jQuery.noConflict();

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

        restoreScrollPosition: function(){
            var y = $.cookie('__F5ScrollY');
            if ( y == null ) return;
            $.cookie('__F5ScrollY', null);
            if (window.pageYOffset!=null) window.pageYOffset = y;
            if (document.documentElement.scrollTop!=null) document.documentElement.scrollTop = y;
            if (window.pageYOffset!=null) window.pageYOffset = y;
            if ( document.body.scrollTop!=null ) document.body.scrollTop = y
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
                return;
            }
            setTimeout(F5.check, 200);
        },

        handle_changes: function(changes){
            F5.refresh();
        },

        refresh: function (){
            var y = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
            $.cookie('__F5ScrollY', y);
            location.reload();
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


