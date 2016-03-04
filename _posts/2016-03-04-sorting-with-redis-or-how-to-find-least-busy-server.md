---
layout: post
title: "Sorting With Redis or How To Find Least Busy Server"
modified: 2016-03-04 09:20:32 -0800
tags: [Redis, DevOps, Load Balancing]
image:
  feature: redis.png
  credit: 
  creditlink: 
comments: true
share: true
---

## Sorting Server IPs By a Property in the Hash

Apparently you can sort [Redis](http://redis.io/) lists by referencing other data structures in your storage.

__[More on Redis Sort command here.](http://redis.io/commands/SORT)__

> Problem described here is an inherited design and doesn't reflect my engineering opinion. I just had to make it work in given ecosystem.

### Problem:

Given a list of hardware servers we need to pull the least busy one from the pool.

Pool in our case is a sorted set of worker ips which is sorted by CPU load in descending order (least busy first). Thus queuer can just take first worker ip in the array and know that's the least busiest worker.


### Infrastructure:

We need a Redis DB running and be accessible by other servers to update information about themselves.

Will use a Redis [Set](http://redis.io/topics/data-types#set) to store our server ips. And Redis [Hashes](http://redis.io/topics/data-types#hashes) to store CPU utilization and some other info about the server.

### Data Structures

{% highlight bash %}
$ redis-cli keys "server*"
1) "server:worker:10.0.1.2"
2) "server:worker:10.0.1.3"
3) "server_ips"
{% endhighlight %}


Here we have two workers and one *server_ips* set

#### Worker

{% highlight bash %}
$ redis-cli hgetall "server:worker:10.0.1.3"
1) "cpu"
2) "0.38"
3) "host"
4) "10.0.1.3"
5) "errors"
6) "0"
7) "type"
8) "worker"
{% endhighlight %}

In JSON that would be 
{% highlight javascript %}
{
  "cpu": "0.38",
  "host": "10.0.1.2",
  "errors": "0",
  "type": "worker"
}

{
  "cpu": "0.50",
  "host": "10.0.1.3",
  "errors": "0",
  "type": "worker"
}
{% endhighlight %}

#### IpSet

{% highlight bash %}
$ redis-cli smembers "server_ips"
1) "10.0.1.3"
2) "10.0.1.2"
{% endhighlight %}

In JSON that would be
{% highlight javascript %}
["10.0.1.3", "10.0.1.2"]
{% endhighlight %}

### Actual Sorting

{% highlight bash %}
127.0.0.1:6379> SORT server_ips BY server:worker*->cpu LIMIT 0 1 DESC
1) "10.0.1.2"
{% endhighlight %}

Since cpu load of our "10.0.1.2" worker is less than "0.50" it's considered the least busy one.

It would be awesome to get entire hash back when you do the sorting, but you can only use *GET* command for hash property.

You can do pretty cool things with if you read the docs.