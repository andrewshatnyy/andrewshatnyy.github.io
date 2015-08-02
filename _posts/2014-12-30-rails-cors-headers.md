---
layout: post
title: "How to set up Cross-origin resource sharing (CORS) headers in rails properly"
modified: 2014-12-30 10:16:03 -0700
tags: [Rails, CORS, Cross-origin resource sharing, jQuery]
image:
  feature: 
  credit: 
  creditlink: 
comments: true
share: true
---

## CORS headers in Rails stack ?

When working with API it's important to set up [CORS headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS) to support Web Client (Browser) requests.

Common solution for most of Rails developers is to create `before_action` with custom headers.

{% highlight ruby %}
def enable_cross_resource sharing
  headers['Access-Control-Allow-Origin'] = '*'
  headers['Access-Control-Allow-Headers'] = 'GET, POST, PUT, DELETE, OPTIONS'
  headers['Access-Control-Allow-Methods'] = 'Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token'
end
{% endhighlight %}

Well that's WRONG. 

What you should do instead is to setup CORS at the (Rack)[http://rack.github.io] middleware level before your Rails routes. Routes only accessible after HTTP OPTIONS method succeeded on the web client.

[Rack Cors](https://github.com/cyu/rack-cors) is helpful if you don't want to write your own middleware.

In `application.rb` make sure that you serve CORS at the top of the stack or at least before middleware you need (in my case I had `Warden::Manager` instead of `0`).

{% highlight ruby %}
config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*',
      :headers => :any,
      :methods => [:get, :post, :delete, :put, :options, :head]
  end
end
{% endhighlight %}

All above is an OK setup for [Heroku](https://heroku.com), (Aptible)[https://www.aptible.com] or other services that allow you to deploy your app with cli gem but won't let you access higher stack like [Nginx](http://nginx.org) or [Apache](http://httpd.apache.org)

"The proper way" of handling Cross-origin is to set it up at the Nginx level. So your Rails app is only busy with serving API. 

Make use of [add_header](http://nginx.org/en/docs/http/ngx_http_headers_module.html) in the `location` context (or `server` if all your server does is serving API)

{% highlight nginx %}
add_header Access-Control-Allow-Headers "X-Requested-With";
add_header Access-Control-Allow-Methods "GET, HEAD, OPTIONS";
add_header Access-Control-Allow-Origin "*";
{% endhighlight %}