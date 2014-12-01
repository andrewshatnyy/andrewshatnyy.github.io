---
layout: post
title: "Google Voice Why No DeleteAll"
modified: 2014-09-21 17:54:03 -0700
tags: [Google Voice, JavaScript, Hack]
image:
  feature: 
  credit: 
  creditlink: 
comments: true
share: true
---

# First post

Today I realized that there are about 2000 of messages / voicemail in my [Google Voice](https://www.google.com/voice) account. By default Google will only allow 10 messages to be removed in one shot. Then you'll find deleted messages in "History" which you also need to clean up.

I hate to leave all this text about me laying around on Google servers.

After searching around all I found is a bunch of posts requesting "delete all" feature. But it seems like Google has more interesting stuff to work on.

I went ahead and created a callback loop of [xhrHttpRequest](http://www.html5rocks.com/en/tutorials/file/xhr2/)s  that will work untill there's nothing to delete in your messages.

So here's the gist of a code that will remove all of your messages from Google voice.

*WARNING: this code will delete everything from your account. So use it cautiously!*

{% gist andrewshatnyy/7ff412c6a255f3100a4f %}

This is first post for the Overengineering blog. I will be posting more usless or usefull stuff as I feel like sharing.

If want some details please let me know in comments...