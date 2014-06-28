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

    iex> 0..9 |> Stream.map(&(&1 + 0.5)) 
    ....      |> Stream.map(fn x -> x * x * x end) 
    ....      |> Stream.map(&(&1 * 2))
    ....      |> Stream.map(fn x -> IO.puts x end)

Isn't that so much better? Even more, the Stream module implements lazy iterators, so we get the same benefits that the python generators give us, in terms of memory usage.
