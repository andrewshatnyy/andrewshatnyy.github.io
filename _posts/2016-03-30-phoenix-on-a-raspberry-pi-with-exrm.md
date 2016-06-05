---
layout: post
title: Phoenix On A Raspberry Pi with Exrm
tags: [Elixir, Erlang, Raspberry Pi, Phoenix, DevOps, Arm, Linux]
image:
  feature: 
  credit: 
  creditlink: 
comments: true
share: true
---

## Intro

> Before you read this be sure to look at:
>
> 1. [Phoenix Advanced Deployment](http://www.phoenixframework.org/docs/advanced-deployment)
> 2. [Exrm Docs](https://exrm.readme.io/docs)
>
> And if you really have ton of time then [learn ye some Erlang](http://learnyousomeerlang.com/release-is-the-word)

If you write [Elixir](elixir-lang.org) and if you question things, then at some point you realize that you need to learn some of [Erlang](https://www.erlang.org/docs) with its [OTP](http://erlang.org/doc/design_principles/users_guide.html).

[Elixir](elixir-lang.org) is like a [Coffee-Script](http://coffeescript.org) for the JavaScript world but with much better support and you almost never need to touch [Erlang](https://www.erlang.org/docs).

Until you want to do some cool stuff like [cross-compiled](http://erlang.org/doc/installation_guide/INSTALL-CROSS.html) deploys.

## Deploying your Elixir App onto ARM-Linux device with [Exrm](https://github.com/bitwalker/exrm)

I have a [Raspberry Pi](https://www.raspberrypi.org/) 1 running [OSMC](https://osmc.tv/) a linux system. I want to run Phoenix application on that box just for fun.

[Exrm](https://exrm.readme.io/docs) and [Phoenix](http://www.phoenixframework.org/docs/advanced-deployment) Docs describe deploy process thoroughly but it works for systems with [Erlang](https://www.erlang.org/) pre-installed.

In order to run an app on a system without `erl` binaries you'd have to build cross compiled version of erlang specifically for that system (in my case that's ARM-linux OSMC).

I failed to do build it manually on OSX. I had to install `erlang-minimal` with help of [Erlang Embedded](http://www.erlang-embedded.com/) guys.

Just follow [this post](http://www.erlang-embedded.com/2013/09/new-erlang-package-for-small-devices-erlang-mini/) to install erlang on your Pi.

You will get erlang build installed in `/usr/lib/erlang/` you can copy that folder to convenient location `/Volumes/Disk/erlang`

That folder is useful for all further deploys to any Pi 

You still would need to tell [Exrm](https://exrm.readme.io/docs) about specific libs before running release. Libs and erts of Erlang built for Pi (`/Volumes/Disk/erlang` see `Configure relx`).

So these are the steps:

### Generate a new Application
{% highlight bash %}
$ mix help phoenix.new --no-brunch
{% endhighlight %}
### Check if it works locally
{% highlight bash %}
$ cd pi
$ mix phoenix.server
{% endhighlight %}
### Install exrm
{% highlight ruby %}
# in mix.exs
defp deps do
  [ ..., {:exrm, "~> 1.0.3"}]
end
{% endhighlight %}

{% highlight bash %}
$ mix deps.get
{% endhighlight %}

### Configure [relx](https://github.com/erlware/relx/wiki/configuration)
{% highlight bash %}
$ mkdir -p rel
$ echo '{include_erts, "/Volumes/Disk/erlang"}.' >> rel/relx.config
$ echo '{system_libs, "/Volumes/Disk/erlang/lib"}.' >> rel/relx.config
{% endhighlight %}

Replace /Volumes/Disk/erlang with a path to the erts extracted from the pi

### Compile the app for prod and build a release
{% highlight bash %}
$ MIX_ENV=prod mix phoenix.digest &&\
  MIX_ENV=prod mix compile &&\
  MIX_ENV=prod mix release
{% endhighlight %}

### Test it:

{% highlight bash %}
$ scp rel/pi/releases/0.0.1/pi.tar.gz tv:~
$ ssh tv
$ cd ~ && mkdir -p app && tar -xzf pi.tar.gz -C ./app
{% endhighlight %}


For details see [Phoenix on Pi repo](https://github.com/andrewshatnyy/phoenix-on-pi)

Please dm me on twitter [Andrew Shatnyy](https://twitter.com/andrewshatnyy) in case there're questions. English is my second language and I am sure this guide could make no sense to a native speaker :)