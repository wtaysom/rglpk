# rglpk 0.2.6 2012-01-23

* Fix memory leaks by adding finalizer to free GLPK problems.

# rglpk 0.2.5 2011-06-23

* Add Row#get_stat, Row#get_prim Row#get_dual.
* Update tests to work with Ruby 1.9.2.

# rglpk 0.2.4 2010-11-04

* Add Rglpk#mip_status.

# rglpk 0.2.3 2010-11-03

* Allow range access of rows and columns.

# rglpk 0.2.2 2010-10-25

* Exclude RDoc generation since we don't yet have any.

# rglpk 0.2.1 2010-10-13

* Point readers to github in README.

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
