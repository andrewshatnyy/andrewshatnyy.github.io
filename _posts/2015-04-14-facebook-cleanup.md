---
layout: post
title: "How to remove all conversations from Facebook"
modified: 2015-04-14 7:10:00 -0700
tags: [Facebook, JavaScript, Security]
image:
  feature: 
  credit: 
  creditlink: 
comments: true
share: true
---

## Annoying Facebook Conversations removal

Messages in Facebook share a lot in common with Google Voice messages. Soon you'll find your inbox full of "Conversations" and there's no way to remove them in bulk.

Here's a bit of vanilla javascript to clean it up.

Just make sure you're:

1. Logged in to Facebook with Google Chrome

2. On [messages page](https://www.facebook.com/messages/) or [archived conversations page](https://www.facebook.com/messages/archived?action=recent-messages)

3. Open console, paste this code and hit return

{% highlight javascript %}

// Make sure you're in Google Chrome:
// 1. Logged in to Facebook
// 2. On https://www.facebook.com/messages
// 3. Open Console and paste following / or create a snippet, save and run it
 
+function() {
    'use strict';
    var findNodeWithText = function(text, type){
      var children = document.querySelectorAll(type);
      var i = 0, node;
      var reg = new RegExp(text, 'g');
      for (; i < children.length; i++) {
        node = children[i];
        if (reg.test(node.textContent)) {
            return node;
        }
      }  
 
    };
 
 
    var remove = function(){
        console.log('remove')
        var evt2 = new Event('click', {
            bubbles: true, 
            cancelable: true
        });
        var el2 = findNodeWithText('Actions', 'button');
 
        console.log('click', el2);
        el2.dispatchEvent(evt2);
 
        var evt = new Event('click', {
            bubbles: true, 
            cancelable: true
        });
        var el = findNodeWithText('Delete Conversation...', 'span');
        el.dispatchEvent(evt);
 
 
        var to = setTimeout(function(){
        var btn = document.querySelector('[name="delete_conversation"]')
        var ev = new Event('click', {
            bubbles: true, 
            cancelable: true
        });
            btn.dispatchEvent(ev);
            clearTimeout(to);
            main();
        }, 300);
    };
 
    var main = function() {
        var to = setTimeout(function(){
            var item = document.querySelector('[role="listitem"] .img');
            var ev = new Event('click', {
                bubbles: true, 
                cancelable: true
            });
            console.log('found list item', item)
            item.dispatchEvent(ev);
            remove();
            clearTimeout(to);
        }, 200);
    }
    main();
}();
{% endhighlight %}

As always, use it at your own risk.