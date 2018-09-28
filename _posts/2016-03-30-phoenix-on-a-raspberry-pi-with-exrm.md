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
> And if you really have a ton of time [learn ye some Erlang](http://learnyousomeerlang.com/release-is-the-word)

## Deploying your Elixir App onto ARM-Linux device with [Exrm](https://github.com/bitwalker/exrm)

I had a [Raspberry Pi](https://www.raspberrypi.org/) 1 running [OSMC](https://osmc.tv/) on my local network for quite a while now and I trust I should be able to host my Phoenix application on that box as well. In Erlang land you need a release to run your app on a remote host. Elixir has [Exrm](https://exrm.readme.io/docs) lib for building releases for mix projects. [Phoenix](http://www.phoenixframework.org/docs/advanced-deployment) Docs describe deploy process thoroughly but it works for systems with [Erlang](https://www.erlang.org/) pre-installed. You are on your own if you want to cross-compile your release from Intel to ARM architecture.

I failed to do build it manually on OSX so I've used `erlang-minimal` with help of [Erlang Embedded](http://www.erlang-embedded.com/) docs. This post [this post](http://www.erlang-embedded.com/2013/09/new-erlang-package-for-small-devices-erlang-mini/) goes over details on how to get minimal runtime up and running.

In essence, you must have a working elrang runtime environment to get your app working, then OpenSSL lib must be present to be able to deal with crypto.

After the installation run, you will get the erlang build installed in `/usr/lib/erlang/` next copy that folder to a convenient location `/Volumes/Disk/erlang`

That folder can be used for all further deploys to most ARM architectures.

Then tell [Exrm](https://exrm.readme.io/docs) about specific libs before running release. Libs and erts of Erlang built for Pi (`/Volumes/Disk/erlang` see `Configure relx`).

These are the steps:

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
