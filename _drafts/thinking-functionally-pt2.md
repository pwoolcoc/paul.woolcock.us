---
layout: post
title: Thinking Functionally Pt. 2
description: Replacing traditional control structures with map, filter, and reduce. And then replacing those.
slug: thinking-functionally-pt-2
---

/* * *
 *
 *  The code examples, right now, are VERY BORING.  EVERYONE does
 *  map/reduce/filter examples with squaring numbers.  This is fine for now,
 *  to write the post around, but I need to come up with a more exciting way
 *  to present the material.
 *
 * * */

## References

- http://www.artima.com/weblogs/viewpost.jsp?thread=98196
- http://bugs.python.org/issue1093
- http://stackoverflow.com/a/231855
- http://www.dabeaz.com/generators/
- http://stackoverflow.com/questions/15995/useful-code-which-uses-reduce-in-python

## Ideas for code examples

1. For `map`, build a little lexer to scan simple strings? Maybe for
i.e. mathematical expressions.  Could use this to add an aside that
points out the similarities between how you read this math expression,
and how you read list comp.

    >>> example_math_expr = u"Q = { a/b | a,b ∈ Z, b ≠ 0 }"
    >>> TOKENS = (
    ...         r'\w', u'IDENTIFIER',
    ...         r'\d+', u'NUMBER',
    ...         u'=', u'EQUAL',
    ...         u'≠', u'NOTEQUAL',
    ...         r'[{}]', u'BRACE',
    ...         r'[+-*/]', u'OPERATOR',
    ...         u'|', u'SUCH_THAT',
    ...         u'∈', u'MEMBER',
    ...         u'∉', u'NOT_MEMBER'
    ...         u'⊆', u'SUBSET',
    ...         u'∅', u'NULL',
    ...         u',', u'COMMA'
    ... )
    >>> def tokenize(char):
    ...     return #lookup(TOKENS, char)
    ...
    >>> [t for t in example_math_expr.split()]
    [IDENTIFIER: Q, ...

## Other notes

I don't like lambdas in python.  Make sure to include a note about why I am
using regular functions instead of lambdas.

## Map

### Naive way

    >>> myoldlist = [1, 2, 3, 4, 5]
    >>> mynewlist = []
    >>> for num in myoldlist:
    ...     mynewlist.append(num * num)
    ...
    >>> mynewlist
    [1, 4, 9, 16, 25]


### Functional way

    >>> def square(num):
    ...     return num * num
    ...
    >>> myoldlist = [1, 2, 3, 4, 5]
    >>> mynewlist = map(square, myoldlist)
    >>> mynewlist
    [1, 4, 9, 16 , 25]


    >>> # or, with imap
    >>> from itertools import imap
    >>> 
    >>> def square(num):
    ...     return num * num
    ...
    >>> myoldlist = [1, 2, 3, 4, 5]
    >>> mynewlist = imap(square, myoldlist)
    >>> mynewlist
    <itertools.imap object at 0x1016d4e10>
    >>> 
    >>> # Retrieve new items one of 2 ways (remember that a generator
    >>> # will only give up its data once):
    >>> list(mynewlist)
    [1, 4, 9, 16, 25]
    >>> 
    >>> # or
    >>> 
    >>> for newitem in mynewlist:
    ...     print newitem
    ...
    1
    4
    9
    16
    25


### Pythonic way

    >>> def square(s):
    ...     return num * num
    ...
    >>> myoldlist = [1, 2, 3, 4, 5]
    >>> mynewlist = [square(x) for x in myoldlist]
    >>> mynewlist
    [1, 4, 9, 16, 25]




## Filter

### Naive way

    >>> myoldlist = [1, 2, 3, 4, 5]
    >>> mynewlist = []
    >>> for item in myoldlist:
    ...     if item > 2:
    ...         mynewlist.append(item)
    ...
    >>> mynewlist
    [3, 4, 5]

### Functional way

    >>> def gt2(num):
    ...     return num > 2
    ...
    >>> myoldlist = [1, 2, 3, 4, 5]
    >>> mynewlist = filter(gt2, myoldlist)
    >>> 
    >>> mynewlist
    [3, 4, 5]

### Pythonic way

    >>> myoldlist = [1, 2, 3, 4, 5]
    >>> mynewlist = [x for x in myoldlist if x > 2]
    >>> mynewlist
    [3, 4, 5]
    >>> 
    >>> # for a more complicated condition
    >>> 
    >>> people = [{'age': 15, 'gender': 'male', 'name': 'Tom'},
    ...           {'age': 47, 'gender': 'female', 'name': 'Ann'},
    ...           {'age': 62, 'gender': 'male', 'name': 'Rupert'}]
    >>> 
    >>> # could get unwieldy
    >>> oldguyslist = [person for person in people if person['age'] > 50 and person['gender'] == 'male']
    >>> oldguyslist
    [{'age': 62, 'name': 'Rupert', 'gender': 'male'}]
    >>> 
    >>> def oldguy(persondict):
    ...     return (persondict['age'] > 50 and persondict['gender'] == 'male')
    ...
    >>> # Eminently readable
    >>> # The condition is more declarative than imperative
    >>> oldguyslist = [person for person in people if oldguy(person)]


## Reduce

*sigh*, reduce...

### Naive^* way

    >>> a = [1, 2, 3, 4, 5]
    >>> value = 0
    >>> for num in a:
    ...     value = value + a
    ...
    >>> print value
    15

### Functional way

    >>> myoldlist = [ 1, 2, 3, 4, 5]
    >>> def sum(x, y):
    ...     return x + y
    ...
    >>> mynewlist = reduce(sum, myoldlist, 0)
    >>> mynewlist
    15

### Functional + pythonic way

    >>> import operator
    >>> from functools import reduce
    >>> 
    >>> myoldlist = [1, 2, 3, 4 ,5]
    >>> mynewlist = reduce(operator.add, myoldlist, 0)

### Pythonic way

    Try to use (or emulate) built-ins where possible.

    >>> # i.e., instead of this:
    >>> import operator
    >>> print reduce(operator.or_, [mybool for mybool in myfunction()])
    >>> 
    >>> # do this instead:
    >>> any([mybool for mybool in myfunction()])
    >>>
    >>> # and instead of this:
    >>> print reduce(operator.and_, [mybool for mybool in myfunction()])
    >>> 
    >>> # do this instead:
    >>> all([mybool for mybool in myfunction()])

These can all be generator expressions instead:

    >>> any(mybool for mybool in myfunction())
    >>> all(mybool for mybool in myfunction())

Also use `sum()`:

    >>> # instead of this:
    >>> print reduce(operator.add, [num for num in mynums()])
    >>> 
    >>> # do this:
    >>> print sum(num for num in mynums())

And you can use the "naive^*" method to emulate `product()`:

    >>> def product(*args):
    ...     """ This doesn't work """
    ...     accum = 1
    ...     for m in args:
    ...         accum = accum * m
    ...     return accum
    ...
    >>> 


