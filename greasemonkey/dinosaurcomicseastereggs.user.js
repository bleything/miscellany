// Dinosaur Comics Easter Eggs NG v0.1
//
// Copyright (c) 2007 Ben Bleything <ben@bleything.net>
// Distributed under the BSD license
//
// ==UserScript==
// @name          Dinosaur Comics Easter Eggs NG
// @namespace     http://bleything.net
// @description   shows the three Dinosaur Comics easter eggs (comic title, RSS title, and comments subject) beneath the comic.  Works for archive pages too!
// @version       0.1
// @include       http://www.qwantz.com/
// @include       http://www.qwantz.com/index.pl?comic=*
// @include       http://qwantz.com/
// @include       http://qwantz.com/index.pl?comic=*
// ==/UserScript==

// // helper from http://wiki.greasespot.net/Code_snippets#XPath_helper
function $x(p, context) {
        if (!context) context = document;
        var i, arr = [], xpr = document.evaluate(p, context, null, XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);
        for (i = 0; item = xpr.snapshotItem(i); i++) arr.push(item);
        return arr;
}

// rss_title looks like this:
//   <span class="rss-title">panel three is pretty straightforward.</span>
// so we need to get rid of the html
var rss_title = $x("/html/body/font/table/tbody/tr/td/table/tbody/tr[4]/td/comment()")[0].textContent;
// rss_title = document.createTextNode( rss_title.substring( 25, (rss_title.length - 8) ) );
rss_title = rss_title.substring( 25, (rss_title.length - 8) );

var comic_img = $x("//img[contains(@src, 'comics')]")[0];
// var comic_title = document.createTextNode( comic_img.getAttribute( 'title' ) );
var comic_title = comic_img.getAttribute( 'title' );

var comments_href = $x("//a[contains(@href, 'mailto')]")[0].href;
// var comments_subject = document.createTextNode( comments_href.substring(31,comments_href.length) );
var comments_subject = comments_href.substring(31,comments_href.length);




// <div id="easter_eggs_container">
var easter_eggs = document.createElement("div");
// easter_eggs.setAttribute( 'id', 'easter_eggs_container' );

//   <div id="comic_title_container">
// var comic_title_container = document.createElement( 'div' );
// comic_title_container.setAttribute( 'id', 'comic_title_container' );

//     <span class="eegg_name">Comic Title</span>
// var comic_title_span = document.createElement( 'span' );
// comic_title_span.setAttribute( 'id', 'comic_title' );
// comic_title_span.insertBefore( comic_title, comic_title_span.lastChild );
// easter_eggs.insertBefore( comic_title_container, easter_eggs.lastChild );

//     <span id="comic_title">Lorem ipsum...</span>
//   <div>
//   <div id="rss_title_container">
//     <span class="eegg_name">RSS Title</span>
//     <span id="comic_title">Lorem ipsum...</span>
//   </div>
//   <div id="comments_subject_container">
//     <span class="eegg_name">Comments Subject</span>
//     <span id="comments_subject">Lorem ipsum...</span>
//   </div>
// </div>
	

easter_eggs.innerHTML += "<b>Comic Title:</b> "      + comic_title + "<br />";
easter_eggs.innerHTML += "<b>RSS Title:</b> "        + rss_title   + "<br />";
easter_eggs.innerHTML += "<b>Comments Subject:</b> " + unescape(comments_subject);

comic_img.parentNode.insertBefore(easter_eggs, comic_img.nextSibling);

// var head = $x( '/html/head' )[0];
// var style = document.createElement( 'style' );
// style.setAttribute( 'type', 'text/css' );
// style.setAttribute( 'ben', 'foo' );
// style.innerHTML = "#easter_eggs_container br { line-height: 1.5em }";
// 
// head.insertBefore( style, head.lastChild );
