---
layout: post
title: Using Rust from Perl and Julia
description: In which we create a shared library with Rust, and use it from Perl and Julia
slug: rust-perl-julia
---

With the recent [runtime removal](), utilizing [Rust]() libraries from
other languages has gotten even easier. In this post I am going to take
the Rust library that {% mention wycats %} used in [this post](), and
use it from both Perl 5, and [Julia]().

## Getting started

    $ cargo new points
    $ cd points
    $ mkdir perl julia
    $ touch perl/points.pl julia/points.jl

Fix cargo to create .so instead of .rlib:

```
[package]

name = "points"
version = "0.0.1"
authors = ["Paul Woolcock <paul@woolcock.us>"]

[lib]

name = "points"
crate-type = ["dylib"]
```

Also, `cargo` by default appends a fingerprint to the lib name, so let's
use a Makefile that will fix it so we have an unchanging lib name:

```make
# Makefile

all:
	cargo build
	ln -fs $(PWD)/target/libpoints-*.so $(PWD)/target/libpoints.so

```

    $ vim src/lib.rs

Ok, let's get started writing the `points` library:

First, we bring some traits into scope from the stdlib that we will
need. Then we define our data structures.

```rust
// src/lib.rs

use std::num::{Int, Float};

#[deriving(Copy)]
pub struct Point { x: int, y: int }

struct Line { p1: Point, p2: Point }

impl Line {
    pub fn length(&self) -> f64 {
        let xdiff = self.p1.x - self.p2.x;
        let ydiff = self.p1.y - self.p2.y;
        ((xdiff.pow(2) + ydiff.pow(2)) as f64).sqrt() 
    }
}
```

Next, we need to define the functions that we will export for use from
the other languages.

```rust
#[no_mangle]
pub extern "C" fn make_point(x: int, y: int) -> Box<Point> {
    box Point { x: x, y: y }
}

#[no_mangle]
pub extern "C" fn get_distance(p1: &Point, p2: &Point) -> f64 {
    Line { p1: *p1, p2: *p2 }.length()
}
```

Finally, add a quick test so we can make sure we get the same result
everywhere.

```rust
#[cfg(test)]
mod tests {
    use super::{Point, get_distance};
    use std::num::FloatMath;

    #[test]
    fn test_get_distance() {
        let p1 = Point { x: 2, y: 2 };
        let p2 = Point { x: 4, y: 4 };
        assert!((get_distance(&p1, &p2).abs_sub(2.828427) < 0.01f64));
    }
}
```

## Using `libpoints` from perl

We will be using `FFI::Raw` instead of XS. `FFI::Raw` is a perl module that
wraps `libffi`, and makes this very easy:

```perl
#!/usr/bin/env perl
use strict;
use warnings;

use FFI::Raw;

my $make_point = FFI::Raw->new(
    "target/libbnconfig.so", # library
    "make_point", # function name
    FFI::Raw::ptr, # return type
    FFI::Raw::int, FFI::Raw::int # argument types
);

my $get_distance = FFI::Raw->new(
    "target/libbnconfig.so",
    "get_distance",
    FFI::Raw::double,
    FFI::Raw::ptr, FFI::Raw::ptr
);

my $one_point = $make_point->call(2,2);
my $two_point = $make_point->call(4, 4);

my $result = $get_distance->call($one_point, $two_point);

say "${result}";

```

Now, let's run it and see what we get:

```bash
$ perl perl/points.pl
2.82842712474619
```

## Using `libpoints` from Julia

[Julia](http://julialang.org) is even easier to use, as it has a C FFI
builtin to the language:

```julia
function make_point(a::Int, b::Int)
  ccall(
      (:make_point, "./target/libpoints"),  # function name & library location
      Ptr{Void}, # return type
      (Int64, Int64),  # argument types
      a, b)  # arguments
end

function get_distance(a::Ptr{Void}, b::Ptr{Void})
  ccall(
      (:get_distance, "./target/libpoints"),
      Float64,
      (Ptr{Void}, Ptr{Void}),
      a, b)
end

t = make_point(2, 2)
u = make_point(4, 4)

println(get_distance(t, u))
```

```bash
$ julia julia/points.jl
2.8284271247461903
```

