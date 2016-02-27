---
layout: post
description: In which I show how awesome Elixir's pipe macro is
title: Elixir and the Pipe macro
slug: elixir-pipe
---

In my [Simple Python Generator](http://paul.woolcock.us/posts/simple-python-generator-example.html) post, I showed how you could use generators to make a pipeline of functions to transform data. Today I am going to show how cool this same technique looks when used in [Elixir](http://elixir-lang.org).

In my python example, we assembled our pipeline like so:

    >>> for result in double(cube(plus_one_half(xrange(10)))):
    ...     print(result)

You see how we had to write the functions in the reverse order than they are actually executed?

Elixir solves this readability issue through use of the the Pipe macro. Here is the code:

    iex(1)> 0..9 |>
    ...(1)      Stream.map(&(&1 + 0.5)) |> 
    ...(1)      Stream.map(fn x -> x * x * x end) |>
    ...(1)      Stream.map(&(&1 * 2)) |>
    ...(1)      Enum.into([])
    [0.25, 6.75, 31.25, 85.75, 182.25, 332.75, 549.25, 843.75, 1228.25, 1714.75]    

Isn't that so much better? Even more, the Stream module implements lazy iterators, so we get the same benefits that the python generators give us, in terms of memory usage.
