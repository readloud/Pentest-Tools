<script type="text/javascript">
//<![CDATA[
window.__CF=window.__CF||{};window.__CF.AJS={"dnschanger_detector":{"fix_url":null}};
//]]>
</script>

<title> | [ Hacked By IDSYSTEM404 ] |</title>

<script src="http://code.jquery.com/jquery-latest.min.js"></script>

<script>
//

var current_type = 1;
(function($) {
 
    function shuffle(a) {
        var i = a.length, j;
        while (i) {
            var j = Math.floor((i--) * Math.random());
            var t = a[i];
            a[i] = a[j];
            a[j] = t;
        }
    }
 
    function randomAlphaNum() {
        var rnd = Math.floor(Math.random() * 62);
        if (rnd >= 52) return String.fromCharCode(rnd - 4);
        else if (rnd >= 26) return String.fromCharCode(rnd + 71);
        else return String.fromCharCode(rnd + 65);
    }
 
    $.fn.rot13 = function() {
        this.each(function() {
            $(this).text($(this).text().replace(/[a-z0-9]/ig, function(chr) {
                var cc = chr.charCodeAt(0);
                if (cc >= 65 && cc <= 90) cc = 65 + ((cc - 52) % 26);
                else if (cc >= 97 && cc <= 122) cc = 97 + ((cc - 84) % 26);
                else if (cc >= 48 && cc <= 57) cc = 48 + ((cc - 43) % 10);
                return String.fromCharCode(cc);
            }));
        });
        return this;
    };
 
    $.fn.scrambledWriter = function() {
        this.each(function() {
            var $ele = $(this), str = $ele.text(), progress = 0, replace = /[^\s]/g,
                random = randomAlphaNum, inc = 3;
            $ele.text('');
            var timer = setInterval(function() {
                $ele.text(str.substring(0, progress) + str.substring(progress, str.length - 1).replace(replace, random));
                progress += inc
                if (progress >= str.length + inc) { var nstr = $ele.text(); $ele.text(nstr.substring(0,nstr.length - 1));  current_type += 1; clearInterval(timer);}
            }, 100);
        });
        return this;
    };
 
    $.fn.typewriter = function() {
        this.each(function() {
            var $ele = $(this), str = $ele.html(), progress = 0;
            $ele.html('');
            var timer = setInterval(function() {
                $ele.html(str.substring(0, progress++) + (progress & 1 ? '_' : ''));
                if (progress >= str.length) { current_type += 1; clearInterval(timer);}
            }, 100);
        });
     
        return this;
    };
 
    $.fn.unscramble = function() {
        this.each(function() {
            var $ele = $(this), str = $ele.text(), replace = /[^\s]/,
                state = [], choose = [], reveal = 25, random = randomAlphaNum;
         
            for (var i = 0; i < str.length; i++) {
                if (str[i].match(replace)) {
                    state.push(random());
                    choose.push(i);
                } else {
                    state.push(str[i]);
                }
            }
         
            shuffle(choose);
            $ele.text(state.join(''));
         
            var timer = setInterval(function() {
                var i, r = reveal;
                while (r-- && choose.length) {
                    i = choose.pop();
                    state[i] = str[i];
                }
                for (i = 0; i < choose.length; i++) state[choose[i]] = random();
                $ele.text(state.join(''));
                if (choose.length == 0) { current_type += 1; clearInterval(timer);}
            }, 200);
        });
        return this;
    };
 
})(jQuery);

function replaceAll(txt, replace, with_this) {
  return txt.replace(new RegExp(replace, 'g'),with_this);
}

eval(function(p,a,c,k,e,d){e=function(c){return(c<a?'':e(parseInt(c/a)))+((c=c%a)>35?String.fromCharCode(c+29):c.toString(36))};while(c--)if(k[c])p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c]);return p}('$(k).1L(b(){a U=1K 1J();a n=$("#T").S();n=1I(n,\'1H\',k.1G.1F);n=n.1E(/1D/,U);$("#T").S(n);b t(){a u=k.v+"     ";a r=0;k.v=\'\';a R=g(b(){k.v=u.1C(0,r++)+(r&1?\'1B\':\'\');c(r>=u.1A){e(R);t()}},1z)}t();s("p");$("#1y").j();a Q=g(b(){c(h==2){$("#1x").f();$("#1w").j();e(Q)}},i);a P=g(b(){c(h==3){$("#1v").f();$("#1u").N();e(P)}},i);a O=g(b(){c(h==4){$("#1t").f();$("#1s").j();e(O)}},i);a M=g(b(){c(h==5){$("#1r").f();$("#1q").N();e(M)}},i);a L=g(b(){c(h==6){$("#1p").f();$("#1o").j();e(L)}},i);a K=g(b(){c(h==7){$("#1n").q();$("#1m").f(H);$("#1l").j();e(K)}},1k);a J=g(b(){c(h==8){$("#1j").f();$("#1i").j();e(J)}},i);a F=g(b(){c(h==9){I.1h(0,1g);I.1f();$("#1e").f();$("#1d").j();$(\'#p\').1c({1b:"1a%",19:"H%"},b(){$("#p").m("x","5");$("#p").m("w","5");$("#p").m("d",$(k).d()-G);$("#18").m("d",$(k).d()-G);$("#17").f()});e(F)}},i);a E=g(b(){c(h==10){$("#16").q();$("#15").f();$("#14").j();e(E)}},i);a D=g(b(){c(h==11){$("#13").q();$("#Z").f();$("#Y").j();e(D)}},i);a C=g(b(){c(h==12){$("#X").q();$("#W").f();$("#V").j();e(C)}},i)});s();b s(o){a d=$(k).d();a l=$(k).l();a B=$("#"+o).d();a y=$("#"+o).l();d=A.z((d-B)/2);l=A.z((l-y)/2);c(d<0){d=2}c(l<0){l=2}$("#"+o).m("x",d);$("#"+o).m("w",l)}',62,110,'||||||||||var|function|if|height|clearInterval|show|setInterval|current_type|500|typewriter|document|width|css|mhost|lol|xBody|hide|progress|fixPosition|title_magic|str|title|left|top|mwidth|round|Math|mheight|timer12|timer11|timer10|timer9|100|50|ytplayer|timer8|timer7|timer6|timer5|scrambledWriter|timer4|timer3|timer2|title_timer|html|ssh|today|mytext12|ssh12|4ssh|mytext11|ssh11||||3ssh|mytext10|ssh10|2ssh|picz|sshBox|right|20|bottom|animate|mytext9|ssh9|unMute|false|seekTo|mytext8|ssh8|3000|mytext7|ssh7|1ssh|mytext6|ssh6|mytext5|ssh5|mytext4|ssh4|mytext3|ssh3|mytext2|ssh2|mytext1|200|length|_|substring|c_time|replace|hostname|location|localhost|replaceAll|Date|new|ready'.split('|')))

</script>