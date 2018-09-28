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

When working with API which is bombarded by XHR requests, which often come from various subdomains, one turns [CORS headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS).

Common solution for most of Rails developers is to create `before_action` with custom headers.

{% highlight ruby %}
def enable_cross_resource sharing
  headers['Access-Control-Allow-Origin'] = '*'
  headers['Access-Control-Allow-Headers'] = 'GET, POST, PUT, DELETE, OPTIONS'
  headers['Access-Control-Allow-Methods'] = 'Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token'
end
{% endhighlight %}

This is an alright solution but I'd suggest moving that into a (Rack)[http://rack.github.io] middleware layer before your Rails router kicks in.
Issue with the controller method is that you must enable OPTIONS response in the rails router to handle requests.

If you don't want to write your own middleware, [Rack Cors](https://github.com/cyu/rack-cors) comes quite handy.

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

That's an 'OK' setup for [Heroku](https://heroku.com), (Aptible)[https://www.aptible.com] or other services, which allow you to deploy your app with cli but won't let you access higher stack like [Nginx](http://nginx.org) or [Apache](http://httpd.apache.org)

The proper way of handling Cross-origin is to set it up at the Nginx/Load-balancer level. So your Rails app is only busy with serving text but not the headers.

For NGINX you can make use of [add_header](http://nginx.org/en/docs/http/ngx_http_headers_module.html) in the `location` context (or `server` if all your server does is serving API)

{% highlight nginx %}
add_header Access-Control-Allow-Headers "X-Requested-With";
add_header Access-Control-Allow-Methods "GET, HEAD, OPTIONS";
add_header Access-Control-Allow-Origin "*";
{% endhighlight %}