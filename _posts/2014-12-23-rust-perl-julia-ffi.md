---
layout: post
title: Using Rust from Perl and Julia
description: In which we create a shared library with Rust, and use it from Perl and Julia
slug: rust-perl-julia-ffi
---

With the recent [runtime removal](https://github.com/rust-lang/rust/commit/0efafac398ff7f28c5f0fe756c15b9008b3e0534),
utilizing [Rust](http://rust-lang.org/) libraries from other languages has gotten even better. In
this post I am going to take the Rust library that <a class="fa fa-twitter mention-twitter" href="https://twitter.com/wycats">wycats</a> used in
[this post](http://blog.skylight.io/bending-the-curve-writing-safe-fast-native-gems-with-rust/),
and use it from both Perl 5, and [Julia](http://julialang.org).

## Getting started
{: .h2 }

{% highlight bash %}
$ cargo new points
$ cd points
$ mkdir perl julia
$ touch Makefile perl/points.pl julia/points.jl
{% endhighlight %}

Fix cargo to create a .so instead of a .rlib:

{% highlight toml %}
# Cargo.toml
[package]

name = "points"
version = "0.0.1"
authors = ["Paul Woolcock <paul@woolcock.us>"]

[lib]

name = "points"
crate-type = ["dylib"]
{% endhighlight %}

Also, `cargo` appends a fingerprint to the lib name, so let's
use a Makefile that will fix it so we have an unchanging lib name:

{% highlight make %}
# Makefile

all:
	cargo build
	ln -fs $(PWD)/target/libpoints-*.so $(PWD)/target/libpoints.so
{% endhighlight %}

Ok, let's get started writing the `points` library:

First, we bring some traits into scope from the stdlib that we will
need. Then we define our data structures.

{% highlight rust %}
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

// rustc 0.13.0-nightly (62fb41c32 2014-12-23 02:41:48 +0000)
{% endhighlight %}

Next, we need to define the functions that we will export for use from
the other languages.

{% highlight rust %}
#[no_mangle]
pub extern "C" fn make_point(x: int, y: int) -> Box<Point> {
    box Point { x: x, y: y }
}

#[no_mangle]
pub extern "C" fn get_distance(p1: &Point, p2: &Point) -> f64 {
    Line { p1: *p1, p2: *p2 }.length()
}

// rustc 0.13.0-nightly (62fb41c32 2014-12-23 02:41:48 +0000)
{% endhighlight %}

Finally, add a quick test so we can make sure we get the same result
everywhere.

{% highlight rust %}
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

// rustc 0.13.0-nightly (62fb41c32 2014-12-23 02:41:48 +0000)
{% endhighlight %}

Now just compile, and we are done writing our Rust library.

{% highlight bash %}
$ cargo test
   Compiling points v0.0.1 (file:///home/paul/projects/points)
     Running target/points-56b2e7a44489e119

running 1 test
test tests::test_get_distance ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured

   Doc-tests points

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured
$ make
cargo build
   Compiling points v0.0.1 (file:///home/paul/projects/points)
ln -fs /home/paul/projects/points/target/libpoints-*.so /home/paul/projects/points/target/libpoints.so
{% endhighlight %}


## Using `libpoints` from perl
{: .h2 }

We will be using `FFI::Raw` instead of XS. `FFI::Raw` is a perl module that
wraps `libffi`, and makes this very easy:

{% highlight perl %}
#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;

use FFI::Raw;

my $make_point = FFI::Raw->new(
    "target/libpoints.so", # library
    "make_point", # function name
    FFI::Raw::ptr, # return type
    FFI::Raw::int, FFI::Raw::int # argument types
);

my $get_distance = FFI::Raw->new(
    "target/libpoints.so",
    "get_distance",
    FFI::Raw::double,
    FFI::Raw::ptr, FFI::Raw::ptr
);

my $one_point = $make_point->call(2,2);
my $two_point = $make_point->call(4, 4);

my $result = $get_distance->call($one_point, $two_point);

say $result;
{% endhighlight %}

Now, let's run it and see what we get:

{% highlight bash %}
$ perl perl/points.pl
2.82842712474619
{% endhighlight %}

## Using `libpoints` from Julia
{: .h2 }

[Julia](http://julialang.org) is even easier to use with our Rust
library, as it has a C FFI builtin to the language:

{% highlight julia %}
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
{% endhighlight %}

{% highlight bash %}
$ julia julia/points.jl
2.8284271247461903
{% endhighlight %}

