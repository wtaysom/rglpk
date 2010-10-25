# rglpk 0.2.2 2010-10-25

* Exclude RDoc generation since we don't yet have any.

# rglpk 0.2.1 2010-10-13

* Point readers to gethub in README.

# rglpk 0.2.0 2010-10-07

* Wrap glpk-4.44 using swig-2.0.0.
* Make Rglpk::RowArray and Rglpk::ColArray into 0-indexed, Enumerable objects (no longer an Array subclass).
* Switch Rakefile to using Jeweler (from Hoe).
* Consolidate build steps in Rakefile.  (No more explicit calls to autoconf, configure, or make required.)
* Add explicit support for integer and binary structural variables.
* Update README.
* Add test cases.

# rglpk 0.1.0 2007-10-24

* First private release.
