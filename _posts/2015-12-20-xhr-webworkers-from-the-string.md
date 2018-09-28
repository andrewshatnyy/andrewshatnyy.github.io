---
layout: post
title: "XhrHttpRequest Webworker from the function"
modified: 2015-12-20 18:10:00 -0800
tags: [JavaScript, Webworkers, Browserify, Node]
image:
  feature:
  credit:
  creditlink:
comments: true
share: true
---


## Loading Images as binary with Webworker built from the function

Few months ago I had to read binary image data from s3 with XHRHttpRequest and then parse ExIf header to determine its orientation.

I had to load and parse numerous images asynchronously. Tried executing it all in one thread; no fun. Browser starts freaking out once I hit 4 images.

Just loading binary image data is a problem.

I am not going to describe the basics of Webworkers in this post. [Html5 Rocks](http://www.html5rocks.com/en/tutorials/workers/basics/) explained it with much better English in 2010.
Please read that linked article, your future self will thank you for investing time in this.

### Goal:
Load and parse images in separate threads and then pass their metadata to the main thread.

My biggest problems with default Webworker loader are versioning and maintenance of separate files. I don’t like extra dependencies in my code unless I must support unstable versions of browsers.

### How:
You can create a Webworker with just a blob of javascript.

{% highlight javascript %}
var blob = new Blob([worker])
var url = URL.createObjectURL(blob)
this.worker = new window.Worker(url)
{% endhighlight %}

Worker here is actually a string I load from browserify module.
Now there’s a problem with maintaining actual text of the worker function. Thank God there’s a way to pull in body of the function in javascript.

Try following in the console you’ll get the result.

{% highlight javascript %}
var worker = function(){
 // body of the function…..
};
var worker_str = worker.toString();
{% endhighlight %}

Please note that there’s a context problem. When you load this to webworker as a blob you’ll start getting weird messages about undefined references. Try calling `self.postMessage`...

I immediately invoke the wrapper function to keep the context.

{% highlight coffeescript %}
var worker = function(){
 // body of the function…..
};
var worker_str = '('+worker.toString()+')(this);';
{% endhighlight %}

Final version with xhr calls minus ExIf parser looks like so:

{% highlight javascript %}
var cached, worker;

cached = null;

worker = function(self) {
  var init, onload, onprogress, xhr;
  xhr = null;
  init = function(url) {
    xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.responseType = 'arraybuffer';
    xhr.onprogress = onprogress;
    xhr.onload = onload;
    xhr.send();
  };
  onprogress = function(evt) {
    if (xhr.status !== 200) {
      return self.close();
    }
    self.postMessage({
      name: 'progress',
      val: {
        loaded: evt.loaded,
        total: evt.total
      }
    });
  };
  onload = function(evt) {
    self.postMessage({
      name: 'onload',
      val: {
        status: xhr.status,
        orientation: xhr.getResponseHeader('x-amz-meta-orientation'),
        array: xhr.response
      }
    }, [xhr.response]);
    self.close();
  };
  self.onmessage = function(evt) {
    init(evt.data);
  };
};

module.exports = function() {
  return cached != null ? cached : cached = '(' + worker.toString() + ')(this);';
};
{% endhighlight %}

And to utilize that module I just require the module and call it in the view:

{% highlight javascript %}
// some backbone jazz
window.URL = window.URL || window.webkitURL;
this.url = options.url
blob = new Blob([worker])
url = URL.createObjectURL(blob)
this.worker = new window.Worker(url)
this.worker.addEventListener('message', this.onMessage)
this.worker.postMessage(this.url)
// rest of the backbone magic
{% endhighlight %}

Now your webworker is passing messages essential to keep main thread informed of the loading and work process. See `onload, onprogress`.

When loading is done it simply kills itself `self.close()`.

Important thing to notice that you should transfer objects not copy them (see about transferrable objects [Html5 Rocks](http://www.html5rocks.com/en/tutorials/workers/basics/#toc-transferrables)).

{% highlight javascript %}
self.postMessage({
  name: 'onload',
  val: {
    status: xhr.status,
    orientation: xhr.getResponseHeader('x-amz-meta-orientation'),
    array: xhr.response
  }
// this last argument allows us to transfer data from the worker to the main thread
}, [xhr.response]);
{% endhighlight %}

And here’s what we do with the image when worker is done:

{% highlight javascript %}
onload: function(val) {
  if (val.status == 200) {
    value = val.orientation
    this.angle = this.interpritAngleFromHeaders(value)
    blob = new Blob([val.array], {type:'image/jpeg'})
    this.image = new Image()
    this.image.onload = this.complete
    this.image.src = window.URL.createObjectURL(blob)
  } else {
    this.$el.removeClass('progress')
    this.render(-1)
  }
}
{% endhighlight %}

Same blob work and ObjectURL.