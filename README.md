workout-music - generate a workout soundtrack with audio markers
================================================================

[![Build Status](https://travis-ci.org/mmitch/workout-music.svg?branch=master)](https://travis-ci.org/mmitch/workout-music)
[![GPL 2+](https://img.shields.io/badge/license-GPL%202%2B-blue.svg)](http://www.gnu.org/licenses/gpl-2.0-standalone.html)


what
----

workout-music takes multiple soundfiles and concatinates them into one
file.  Audio markers will be added to the resulting file at regular
intervals.


why
---

It is intended to create a soundtrack for a sports workout (runnning,
cycling, ..., you name it) with alternating phases like "5 minutes of
slow running followed by 2 minutes of fast running".  The inserted
audio markers will tell you when the 2 or 5 minutes are over.

The input files can be anything you like, eg. music or podcasts or
just ambient sounds like rain or bird calls.


how to use
----------

```
usage:
  workout-music [options] input [input [...]]

arguments:
  input      one or more input files

options:
  -h         show help
  -n         make-believe mode:
             show what would be done, but don't really do it
  -o output  set output file (default: /tmp/workout.mp3)
  -t total   set total time for generated soundtrack (unit: seconds)
```


where to get it
---------------

workout-music source is hosted at https://github.com/mmitch/workout-music


copyright
---------

Copyright (C) 2016  Christian Garbs <mitch@cgarbs.de>  
Licensed under GNU GPL v2 or later.
