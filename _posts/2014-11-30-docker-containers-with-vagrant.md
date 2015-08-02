---
layout: post
title: "Quickly up and running with Docker containers via Vagrant host machine"
modified: 2014-11-30 10:06:03 -0700
tags: [Vagrant, Docker, VirtualBox, Deploy, Devops]
image:
  feature: 
  credit: 
  creditlink: 
comments: true
share: true
---

## Fun with Vagrant and Docker containers

This article requires some knowledge about [Vagrant](https://www.vagrantup.com/) and [Docker](https://www.docker.com).

Almost any reasonable deploy process now requires a docker box. Docker is awesome but I'd rather have an isolated environment for my containers.

Here is where vagrant's [docker priovider](https://docs.vagrantup.com/v2/docker/index.html) comes in to play. Vagrant guys did a great job explaining abstraction [here](http://www.vagrantup.com/blog/feature-preview-vagrant-1-6-docker-dev-environments.html).

As always things are not so easy when you actually try to implement Vagrant Docker Proxy/Host on your own.

After a day of googling errors caused by `vagrant up` [I figured](https://github.com/phusion/open-vagrant-boxes/issues/12) that Vagrant is too green for automating Docker installation. 
Another [issue](https://gist.github.com/kjellski/6158747) came up after I failed to install Docker on linux box.
Even if you get Docker instaled you instantly get [a permission error](https://github.com/docker/docker/issues/5314).

All issues above fixed with custom `shell.sh` provision script:
{% highlight bash %}
#!/bin/bash
sudo apt-get update &&
sudo apt-get install curl -y &&
curl -sSL https://get.docker.com/ubuntu/ | sudo sh &&
sudo usermod -a -G docker vagrant &&
ps aux | grep 'sshd:' | awk '{print $2}' | xargs kill
{% endhighlight %}

`curl -sSL https://get.docker.com/ubuntu/ | sudo sh &&` will take care of installing correct binaries.

Here's working `Vagrantfile` for host machine:
{% highlight ruby %}
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|

  config.vm.provision "shell", path: "shell.sh"
  config.vm.box = "ubuntu/trusty64"
 
  config.vm.provider :virtualbox do |vb|
      vb.name = "dockerhost"
  end
end
{% endhighlight %}

Then you can reference other containers in main `Vagrantfile`

{% highlight ruby %}
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "docker" do |v|
    v.vagrant_vagrantfile = "./docker-host/Vagrantfile"
  end

  config.vm.define "core" do |v|
    v.vm.provider "docker" do |d|
      d.build_dir = "."
    end
  end

  config.vm.define "db" do |v|
    v.vm.provider "docker" do |d|
      d.image = "paintedfox/postgresql"
      d.name = "db"
    end 
  end
end
{% endhighlight%}

That's it!