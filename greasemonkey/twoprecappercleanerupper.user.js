// ==UserScript==
// @name           TWoP recapper cleaner upper....er
// @namespace      http://bleything.net
// @description    Removes a bunch of random crap from twop recaps
// @include        http://televisionwithoutpity.com/*
// @include        http://*.televisionwithoutpity.com/*
// ==/UserScript==

// // helper from http://wiki.greasespot.net/Code_snippets#XPath_helper
function $x(p, context) {
        if (!context) context = document;
        var i, arr = [], xpr = document.evaluate(p, context, null, XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);
        for (i = 0; item = xpr.snapshotItem(i); i++) arr.push(item);
        return arr;
}

var topbar = $x( "/html/body/table/tbody/tr/td/table/tbody/tr[4]/td/table" )[0];
var bottombar = $x( "/html/body/table/tbody/tr/td/table/tbody/tr[6]/td/table" )[0];
var rightbar = $x( "/html/body/table/tbody/tr/td/table/tbody/tr[5]/td/table/tbody/tr/td[2]" )[0];

topbar.parentNode.removeChild( topbar );
bottombar.parentNode.removeChild( bottombar );
rightbar.parentNode.removeChild( rightbar );

var main = $x( "/html/body/table/tbody/tr/td/table/tbody/tr[5]/td/table/tbody/tr/td" )[0];
main.setAttribute( 'width', '100%' );