---
layout: post
description: In which I present a quick example of generator pipelines.
title: Simple Python Generator Example
slug: python-generators
---


So I have read this amazing lesson before: [Generator Tricks for
System Programmers](http://www.dabeaz.com/generators/), and I thought I would write up a quick example to show the
effect of the “pipeline” that strings of generators set up. No long
tutorial here, just a simple example.

Here we have three functions, each one performing some numeric operation
on each entry in a list of numbers:

    >>> def plus_one_half(nums):
    ...     for num in nums:
    ...         print("adding 1/2 to {num}".format(num=num))
    ...         yield (num + 0.5)

    >>> def double(nums):
    ...     for num in nums:
    ...         print("doubling {num}".format(num=num))
    ...         yield (num * 2)

    >>> def cube(nums):
    ...     for num in nums:
    ...         print("cubing {num}".format(num=num))
    ...         yield (num ** 3)

Notice that all of them are actually generators (not functions), as they
use the yield keyword instead of return.

When we set up a generator pipeline, we can see how each value is only
retrieved when it is needed:

    >>> for result in double(cube(plus_one_half(xrange(10)))):
    ...     print("result is {result}".format(result=result))
    ...     print("---")

This prints out:

    adding 1/2 to 0
    cubing 0.5
    doubling 0.125
    result is: 0.25
    ---
    adding 1/2 to 1
    cubing 1.5
    doubling 3.375
    result is: 6.75
    ---
    adding 1/2 to 2
    cubing 2.5
    doubling 15.625
    result is: 31.25
    ---
    adding 1/2 to 3
    cubing 3.5
    doubling 42.875
    result is: 85.75
    ---
    adding 1/2 to 4
    cubing 4.5
    doubling 91.125
    result is: 182.25
    ---
    adding 1/2 to 5
    cubing 5.5
    doubling 166.375
    result is: 332.75
    ---
    adding 1/2 to 6
    cubing 6.5
    doubling 274.625
    result is: 549.25
    ---
    adding 1/2 to 7
    cubing 7.5
    doubling 421.875
    result is: 843.75
    ---
    adding 1/2 to 8
    cubing 8.5
    doubling 614.125
    result is: 1228.25
    ---
    adding 1/2 to 9
    cubing 9.5
    doubling 857.375
    result is: 1714.75
    ---

Here we can clearly see how each generator runs until it yields, then
passes control to the next generator in the pipeline. Neat!

If you did this without generators, you would have to change the
functions to build and return lists.

(Actually, you would probably use list comprehensions, but we are going
to do it this way so we can still easily include the call to print)

    >>> def plus_one_half(nums):
    ...     result = []
    ...     for num in nums:
    ...         print("adding 1/2 to {num}".format(num=num))
    ...         result.append(num + 0.5)
    ...     return result

    >>> def double(nums):
    ...     result = []
    ...     for num in nums:
    ...         print("doubling {num}".format(num=num))
    ...         result.append(num * 2)
    ...     return result

    >>> def cube(nums):
    ...     result = []
    ...     for num in nums:
    ...         print("cubing {num}".format(num=num))
    ...         result.append(num ** 3)
    ...     return result

The code is similar, except now we need a list to store the results of
the computations in each function. It also means that instead of
generating a value and then passing control to the next function, each
function performs it’s transformation on the entire list of numbers
before returning, as we can see here:

    >>> for result in double(cube(plus_one_half(xrange(10)))):
    ...     print("result is {result}".format(result=result))
    ...     print("---")

and the results:

    adding 1/2 to 0
    adding 1/2 to 1
    adding 1/2 to 2
    adding 1/2 to 3
    adding 1/2 to 4
    adding 1/2 to 5
    adding 1/2 to 6
    adding 1/2 to 7
    adding 1/2 to 8
    adding 1/2 to 9
    cubing 0.5
    cubing 1.5
    cubing 2.5
    cubing 3.5
    cubing 4.5
    cubing 5.5
    cubing 6.5
    cubing 7.5
    cubing 8.5
    cubing 9.5
    doubling 0.125
    doubling 3.375
    doubling 15.625
    doubling 42.875
    doubling 91.125
    doubling 166.375
    doubling 274.625
    doubling 421.875
    doubling 614.125
    doubling 857.375
    result is: 0.25
    ---
    result is: 6.75
    ---
    result is: 31.25
    ---
    result is: 85.75
    ---
    result is: 182.25
    ---
    result is: 332.75
    ---
    result is: 549.25
    ---
    result is: 843.75
    ---
    result is: 1228.25
    ---
    result is: 1714.75
    ---

As a result of these differences, the generator pipeline needs to keep
much less information in memory at any given time than the list example.

