---
layout: post
title: Thinking Functionally Pt. 2
description: Replacing traditional control structures with map, filter, and reduce. And then replacing those.
slug: thinking-functionally-pt-2
---

## Map

### Naive way

    >>> myoldlist = [u'one', u'two', u'three', u'four', u'five', u'six']
    >>> mynewlist = []
    >>> for item in myoldlist:
    ...     newstring = u'This is string number {num}'.format(num=item)
    ...     mynewlist.append(newstring)
    ... 
    >>> mynewlist
    [u'This is string number one',
     u'This is string number two',
     u'This is string number three',
     u'This is string number four',
     u'This is string number five',
     u'This is string number six']


### Functional way

    >>> def transform_str(s):
    ...     fmt = u'This is string number {num}'
    ...     return fmt.format(num=s)
    ...
    >>> myoldlist = [u'one', u'two', u'three', u'four', u'five', u'six']
    >>> mynewlist = map(transform_str, myoldlist)
    >>> mynewlist
    [u'This is string number one',
     u'This is string number two',
     u'This is string number three',
     u'This is string number four',
     u'This is string number five',
     u'This is string number six']


    >>> # or, with imap
    >>> from itertools import imap
    >>> 
    >>> mynewlist = imap(transform_str, myoldlist)
    >>> mynewlist
    <itertools.imap object at 0x1016d4e10>
    >>> 
    >>> # Retrieve new items one of 2 ways (remember that a generator
    >>> # will only give up its data once):
    >>> list(mynewlist)
    [u'This is string number one',
     u'This is string number two',
     u'This is string number three',
     u'This is string number four',
     u'This is string number five',
     u'This is string number six']
    >>> 
    >>> # or
    >>> 
    >>> for newitem in mynewlist:
    ...     print newitem
    ...
    This is string number one
    This is string number two
    This is string number three
    This is string number four
    This is string number five
    This is string number six


### Pythonic way

    >>> def transform_str(s):
    ...     fmt = u'This is string number {num}'
    ...     return fmt.format(num=s)
    ...
    >>> myoldlist = [u'one', u'two', u'three', u'four', u'five', u'six']
    >>> mynewlist = [transform_str(s) for s in myoldlist]

