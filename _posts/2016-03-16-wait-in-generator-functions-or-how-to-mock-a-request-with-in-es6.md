---
layout: post
title: Wait in generator functions or how to mock a request in ES6
tags: [ES6, JavaScript, testing, mocha]
---

## Testing requests with generator functions ES6 style

I was implementing an async retrier while refactoring some callback hell.
And while testing it I realized that there's a simple way to make your generators wait.

{% highlight javascript %}
'use strict';

function wait(done) {
  setTimeout(done, 1000);
}
{% endhighlight %}

That's it. Function above is perfectly yieldable and will suspend your generator.

So in practice your test would look like this.


{% highlight javascript %}
'use strict';

function wait(time) {
  return function wait(done) {
    setTimeout(done, time);
  };  
}

describe('Retry', () => {
  it('retries 3 failed att', function* times3() {
    // tell mocha to wait longer
    this.timeout(8000);

    let total = 3;
    function* req() {
      while (true) {
        // our awesome wait function
        yield wait(1000);
        if (total-- === 1) {
          return 'done';
        }
        throw new Error('test');
      }
    }
    const result = yield retry(req, { times: 4 });
    assert.equal(result, 'done');
  });
});
{% endhighlight %}

I use [co-mocha](https://github.com/blakeembrey/co-mocha) for generator tests, hence `function* times3` callback.

Wait function also works in Chrome console in case you want to check it out (don't forget to use strict).