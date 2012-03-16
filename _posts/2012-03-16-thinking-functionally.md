---
layout: post
description: In which I realize that working in a functional language is much different from working in imperative languages.
title: Thinking Functionally
---

## Easy problem made hard

I have been messing around with Clojure quite a bit lately, and have been enjoying
the challenges that come from learning a programming language that uses a different
paradigm than what I am used to.

Today, I was messing around with Clojure's java interop and writing some Swing
stuff.  I won't mention the project yet, because I am still kicking it around,
but I am pretty excited about it.

Anyway, I came across a simple problem, and because I am not thinking “functionally”
enough yet, I made it much harder than it needed to be.

The problem boiled down to this: lets say you need an array of objects that are
mostly the same, except for the fact that each object includes an incremented
integer.  So, for fun, let's say we want to end up with this:

    '("This is number: 0" "This is number: 1" "This is number: 2"
      "This is number: 3" "This is number: 4")

Easy, right?  Of course, my imperative brain immediately starting
thinking of what kind of looping construct I would need to use to get this
result.  My first thought was that there had to be a function in `clojure.core`
that could do this.  Of course, I started looking in the wrong direction.
My first thought was something like this:

    ; Clojure experts: Please don't cringe too hard, you'll pull something

    (defn make-string [num]
	  (format "This is number: %d" num))

    (def string-list
      (into '()
        (loop [i 0]
          (if (< i 5)
              (make-string i)
            (recur (+ i 1))))))

Of course, this is pretty obviously a case of trying to apply imperative thinking
to a functional language.  I'm telling the computer *how* to do
something instead of telling it *what* to do.

I also did some messing around with the `repeatedly` function, as well as the
`take-while` function, but I am not going to include those examples here, as I
feel stupid enough already.

Finally, I realized how much harder I was making this than I really needed to:

    (map make-string (range 5))

Or, if I wanted to package this up into a little generator function:

    (defn make-strings []
      (map make-string (range)))

So that I could later do something like this:

    (take 28 (make-strings))

It has taken a little getting used to, but I think I am starting to get
the hang of it.  I have also started reading
[On Lisp](http://www.paulgraham.com/onlisp.html) by Paul Graham,
and even though he is writing in Common Lisp in it, his points about bottom
up design have really helped me in thinking about how to structure my
Clojure programs.

