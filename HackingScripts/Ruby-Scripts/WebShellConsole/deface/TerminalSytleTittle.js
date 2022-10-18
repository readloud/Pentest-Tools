var brzinakucanja = 200;
var pauzapor = 2000;
var vremeid = null;
var kretanje = false;
var poruka = new Array();
var slporuka = 0;
var bezporuke = 0;
poruka[0] = " | [ Hacked By IDSYSTEM404 ] |
function prikaz() {
var text = poruka[slporuka];
if (bezporuke < text.length) {
if (text.charAt(bezporuke) == " ")
bezporuke++
var ttporuka = text.substring(0, bezporuke + 1);
document.title = ttporuka;
bezporuke++
vremeid = setTimeout("prikaz()", brzinakucanja);
kretanje = true;
} else {
bezporuke = 0;
slporuka++
if (slporuka == poruka.length)
slporuka = 0;
vremeid = setTimeout("prikaz()", pauzapor);
kretanje = true;
}
}
function stop() {
if (kretanje)
clearTimeout(vremeid);
kretanje = false
}
function start() {
stop();
prikaz();
}
start();