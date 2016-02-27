---
layout: post
title: Survey of licenses used by Rust projects on crates.io
description: In which I figure out which licenses Rustaceans use the most
slug: crates-io-license-survey
---

So I am working on a feature that I hope to get merged into `cargo`,
Rusts package manager. The feature would allow a developer to specify a
license to add to a new project (or all new projects), and automatically
put that information in their `Cargo.toml`, as well as add the `LICENSE`
file to their project.

So I got to the point where the feature was working, but I had to figure out
how many, and which licenses, to support in the tool. My intuition was to
include: MIT, BSD (2- and 3-clause), Apache-2.0, and GPL, both -2.0 and -3.0.

However, we are all about data these days, right? So forget my intuition, let's
see what actual Rustaceans are using!

## Process

So my first step was to collect some data from `crates.io`, the central repository
for Rust crates. You can easily get an index of all the crates on the site by
using the index that the Cargo team has on github:

{% highlight bash %}
$ git clone https://github.com/crates.io-index
$ cd crates.io-index
{% endhighlight %}

Now, lets query the `crates.io` API for information about these crates.
I ended up saving the information to a file, though you don't necessarily have to
do that. It helped with iterating on the data, as I didn't have to repeatedly hit
crates.io's servers for the info (it saved them bandwidth, and me time, since
crates.io _will_ cut you off if you make too many requests in too short a time).

Here is the script I used to gather the data:

{% highlight python %}
import csv
import os
import time

import requests

CRATE_URL = "https://crates.io/api/v1/crates/{crate_name}"
INDEX_PATH = "/path/to/crates.io-index"

def walk_index(path):
    for _, _, fnames in os.walk(path):
        for fname in fnames:
            if not fname == "config.json":
                yield fname

def get_license(crate_name):
    req = requests.get(CRATE_URL.format(crate_name=crate_name))
    if req.status_code == requests.codes.ok:
        try:
            j = req.json()
            crate = j['crate']
            license = crate['license']
            if license is not None:
                license = license.lower()
            return license
        except KeyError:
            return None
        except ValueError:
            return None
    return None

with open("license.csv", "w", newline="") as csvfile:
    writer = csv.writer(csvfile, dialect='excel')
    for crate_name in walk_index(INDEX_PATH):
        license = get_license(crate_name)
        writer.writerow([crate_name, license])
        # The crates.io API will cut you off if you
        # don't throttle your requests a bit
        time.sleep(0.5)
{% endhighlight %}

Ok, so now we have a nice `.csv` file with the name of the crate and the license string it
uses. Now, lets re-read that information back in, and count licenses:

{% highlight python %}
import csv
from collections import Counter

license_counter = Counter()

with open("license.csv") as csvfile:
    data = csv.reader(csvfile, dialect='excel')
    for crate_name, row in data:
        # some projects multi-license, and they almost always use a '/' to join
        # the license names
        licenses = row.split("/")
        for license in licenses:
            # we just want the general class of the license,
            # so the trailing '+' characters are unnecessary
            cleaned = license.strip().rstrip("+")
            if cleaned:
                license_counter.update([cleaned])

for x, n in license_counter.most_common():
    print("{x:30}{n}".format(x=x, n=n))
{% endhighlight %}

## Results

So what were the results? Well, my intuition was about half correct. The top 2
most-used licenses were the MIT license and Apache-2.0. After that the number
of projects using a particular license drops off considerably, with the
BSD-3-Clause coming in 3rd. The Mozilla Public License came in 4th. I did not
have the MPL on my list, which was obviously foolish, considering Rust is a
Mozilla project. "non-standard" came in 5th, but that is kind of a wash because
it appears to be a kind of "default value" that cargo (or crates.io) gives the
project when they don't have a "license" key in their configuration, but rather
a "license-file" which has a path. The handful of these that I looked at were
using MIT, but just didn't name it in their `Cargo.toml` configs. It made me
chuckle, but the "Unlicense" came in 6th. The GPL-3.0 is at 7, and the
BSD-2-Clause at 8th.  So all the licenses from my list were in the top 8, but
were definitely not the top 5. Here is a table of my counts:

        mit                           2333
        apache-2.0                    488
        bsd-3-clause                  63
        mpl-2.0                       52
        non-standard                  52
        unlicense                     49
        gpl-3.0                       47
        bsd-2-clause                  40
        cc0-1.0                       38
        lgpl-3.0                      31
        zlib                          26
        isc                           24
        wtfpl                         23
        lgpl-2.1                      19
        gpl-2.0                       18
        bsl-1.0                       15
        agpl-3.0                      9
        aml                           4
        cc-by-nc-4.0                  2
        python-2.0                    2
        apache-1.0                    1
        agpl-1.0                      1
        lgpl-2.0                      1
        nlpl                          1
        ncsa                          1
        zlib-acknowledgement          1
        ijg                           1
        libpng                        1
        mpl-2.0-no-copyleft-exception 1
        zed                           1
        miros                         1
        mpl-1.1                       1

## Conclusion

Given the results, I am probably going to take the GPL-3.0 and BSD-2-Clause out
of my PR, and add the MPL in. The "Unlicense" seems to be slightly controversial
(at least from the little digging I did on the internet), but I don't want to
exclude it while including licenses that were represented less in the data, so
taking the top 4 instead of the top 5 seems more fair.

I am not sure if the cargo devs will be interested in my feature when I get a
PR opened, but either way I enjoyed this quick little dip into the crates.io
ecosystem.

#### Notes

If you want to see the data I worked from, and the scripts I used, there
is a git repo up with all the files, at
[https://github.com/pwoolcoc/crates.io-license-survey](https://github.com/pwoolcoc/crates.io-license-survey)
