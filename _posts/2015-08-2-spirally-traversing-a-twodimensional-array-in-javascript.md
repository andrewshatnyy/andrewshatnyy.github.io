---
layout: post
title: "Spirally Traversing a Two-Dimensional Array in JavaScript (ES5 - no recursion)"
modified: 2015-08-3 13:10:00 -0800
tags: [JavaScript, Interview]
image:
  feature: 
  credit: 
  creditlink: 
comments: true
share: true
---

## Given two-dimensional array now walk it spirally

One of those brain-twisters you might be asked if you apply for Software Engineer position at a decent company.

The interviewer goes to the white board and draws a 2d array.

{% highlight javascript %}
var array = [
    [1,2,3],
    [4,5,6],
    [7,8,9]
];
{% endhighlight %}

Write a function that walks that array in spiral and outputs:

{% highlight javascript %}
'1,2,3,6,9,8,7,4,5';
{% endhighlight %}


## How to walk it spirally (over engineered)

Like always with programming there are tons of ways to tackle a problem. However, only efficient solutions counts.

Here's my take on this one:

1. Shave off sides of the 2d matrix(array)
2. Append contents of the side to result array

{% highlight javascript %}
var array = [
    [1,2,3],
    [4,5,6],
    [7,8,9]
];
// shave 1 (top)
var result = [1,2,3];

var array = [
    [4,5,6],
    [7,8,9]
];
// shave 2 (right)
var result = [1,2,3,6,9];

var array = [
    [4,5],
    [7,8]
];
// shave 3 (bottom)
var result = [1,2,3,6,9,8,7];

var array = [
    [4,5]
];
// shave 4 (left)
var result = [1,2,3,6,9,8,7,4];

var array = [
    [5]
];
// shave 5 (top)
var result = [1,2,3,6,9,8,7,4,5];

var array = [
    []
];

return result.join(',');
{% endhighlight %}

"Hold ye horses sire... How the hell did you shave sides off?", I hear you cry.

The answer is that we have to [transpose](https://en.wikipedia.org/wiki/Transpose) the matrix every time before we take off one side. But not the first time!

Basically we need to turn that two-dimensional array -90° and take the top off (shave).

In any case, we've just identified two main functions here

* `transpose` to turn the matrix
* `spiral`  to shave off top row

{% highlight javascript %}
[1,2,3],
[4,5,6],
[7,8,9]
// -90 =>
[3,6,9],
[2,5,8],
[1,4,7]
{% endhighlight %}

Let's write some tests for these functions

{% highlight javascript %}
var M = require('../lib/matrix');
describe('Matrix', function() {

  it('walks spiral', function(){
    var result = M.spiral([
      [1,2,3],
      [4,5,6],
      [7,8,9]
    ]);
    expect(result).toEqual('1,2,3,6,9,8,7,4,5');
  });

  it('transposes 3x3', function() {
    var result = M.transpose([
      [1,2,3],
      [4,5,6],
      [7,8,9]
    ]);
    expect(result).toEqual([
      [3,6,9],
      [2,5,8],
      [1,4,7]
    ]);
  });

  it('transposes 2x3', function(){
    var result = M.transpose([
      [4,5,6],
      [7,8,9]
    ]);
    expect(result).toEqual([
      [6,9],
      [5,8],
      [4,7]
    ]);
  });
});
{% endhighlight %}

We would have to use `while` loops in `spiral` to mimic recursion as JavaScript does not yet fully support [tail call optimisation](https://en.wikipedia.org/wiki/Tail_call). [Read more about es6](http://duartes.org/gustavo/blog/post/tail-calls-optimization-es6/).

Code below will make our tests pass.

{% highlight javascript %}
function spiral(array) {
  var width = array[0].length;
  var height = array.length;
  var row, index=0;
  var result = new Array(width*height);
  // or
  //var result=[];

  // mutate original array
  // use it as a stack

  // recursion goes here in es6

  while(array.length) {
    row = array.shift();
    while(row.length) {
      result[index++] = row.shift();
      // or
      // result.push(row.shift());
    }
    array = transpose(array);
  }
  return result.join(',');
}

function transpose(array) {

  var column = array[0];
  if (!column) return array;

  var columns = column.length;
  var rows = array.length;
  var result = new Array(columns);
  // or
  // var result = [];
  var columnIndex,
      resultColumnIndex,
      rowIndex;
  
  // turn matrix
  // [o,o,x]
  // [o,o,x]
  // into
  // [x,x]
  // [o,o]
  // [o,o]

  for(resultColumnIndex = 0, columnIndex = columns -1; columnIndex >= 0; columnIndex--, resultColumnIndex++) {
    result[resultColumnIndex] = new Array(rows);
    // or
    // result.push([]);
    for(rowIndex = 0; rowIndex < rows; rowIndex++) {
      result[resultColumnIndex][rowIndex] = array[rowIndex][columnIndex];
    }
  }
  return result;
}

module.exports = {
  transpose: transpose,
  spiral: spiral
};
{% endhighlight %}

Awesome, right? Well, NO.

## How to really walk two-dimensional array spirally

Obviously, the solution above is over engineered and most likely you won't get a job :(. It's fun to play with matrixes but when it comes to real life you should never use code described above in production.

The spiral problem is solved by keeping track of the coordinates for the traversed two-dimensional array.

* identify coordinates `topIndex`, `bottomIndex`, `leftIndex`, `rightIndex`

{% highlight javascript %}
[top ,o,o,o,  o]
[left,o,o,o,  o]
[o   ,o,o,o,rgt]
[btm ,o,o,o,  o]
{% endhighlight %}

* keep a reference of a current side being shaved off

{% highlight javascript %}

function spiral(array) {
  var rows = array.length;
  var columns = array[0].length;
  var topIndex = 0;
  var bottomIndex = rows - 1;
  var leftIndex = 0;
  var rightIndex = columns - 1;

  var result = [];

  var side = 'top';
  var i;

  while(topIndex <= bottomIndex && leftIndex <= rightIndex) {
    
    if (side === 'top') {
      for(i = leftIndex; i <= rightIndex; i++) {
        result.push(array[topIndex][i]);
      }
      topIndex++;
      side = 'right';
      continue;
    }
    if (side === 'right') {
      for(i = topIndex; i <= bottomIndex; i++) {
        result.push(array[i][rightIndex]);
      }
      rightIndex--;
      side = 'bottom';
      continue;
    }
    if (side === 'bottom') {
      for(i = rightIndex; i >= leftIndex; i--) {
        result.push(array[bottomIndex][i]);
      }
      bottomIndex--;
      side = 'left';
      continue;
    }
    if (side === 'left') {
      for(i = bottomIndex; i >= topIndex; i--) {
        result.push(array[i][leftIndex]);
      }
      leftIndex++;
      side = 'top';
      continue;
    }
  }

  return result.join(',');

}
{% endhighlight %}


Function above runs 80% faster than overengineered solution, in which you need to rotate arrays.

{% highlight bash %}
spiral x 882,768 ops/sec ±0.80% (84 runs sampled)
{% endhighlight %}