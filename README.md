# Introduction

Rglpk is a package providing a Ruby wrapper to the [GNU GLPK](http://www.gnu.org/software/glpk/) library.  The GLPK (GNU Linear Programming Kit) package is intended for solving large-scale linear programming (LP), mixed integer programming (MIP), and other related problems.

Rglpk (pronounced as "wriggle-pick") is currently in alpha status and the API should be considered subject to change.  Rglpk uses [Swig](http://www.swig.org/) to initially wrap the C GLPK library (using a Swig wrapper originally developed by Nigel Galloway) and then a pure Ruby library to wrap the Swig code in a more friendly OO-style.

See [github](http://github.com/wtaysom/rglpk) for installation instructions.  All bug reports, feature requests and patches are welcome.  Enjoy!

# Installation

A working GLPK library installation is required.  Currently, Rglpk is tested with GLPK v4.44 ([direct download](http://ftp.gnu.org/gnu/glpk/glpk-4.44.tar.gz)).  To install GLPK, follow standard procedure:

	> gzip -d glpk-X.Y.tar.gz
	> tar -x < glpk-X.Y.tar
	> ./configure
	> make
	> make check
	> make install

Rglpk is only available as a gem:

	> gem install rglpk

The underlying C library is wrapped using Swig.  We keep an up-to-date copy of the generated glpk_wrapper.c file with the distribution, so you don't need to install Swig if you don't want to.

# Documentation

Rglpk provides two primary files: ext/glpk_wrapper.c which is a Swig generated wrapper and lib/rglpk.rb which provide a nicer OO-orientated interface.  You should only ever need to call methods of the Rglpk class defined lib/rglpk.rb.

An example:

	# The same Brief Example as found in section 1.3 of 
	# glpk-4.44/doc/glpk.pdf.
	#
	# maximize
	#   z = 10 * x1 + 6 * x2 + 4 * x3
	#
	# subject to
	#   p:      x1 +     x2 +     x3 <= 100
	#   q: 10 * x1 + 4 * x2 + 5 * x3 <= 600
	#   r:  2 * x1 + 2 * x2 + 6 * x3 <= 300
	#
	# where all variables are non-negative
	#   x1 >= 0, x2 >= 0, x3 >= 0
	#    
	p = Rglpk::Problem.new
	p.name = "sample"
	p.obj.dir = Rglpk::GLP_MAX

	rows = p.add_rows(3)
	rows[0].name = "p"
	rows[0].set_bounds(Rglpk::GLP_UP, 0, 100)
	rows[1].name = "q"
	rows[1].set_bounds(Rglpk::GLP_UP, 0, 600)
	rows[2].name = "r"
	rows[2].set_bounds(Rglpk::GLP_UP, 0, 300)

	cols = p.add_cols(3)
	cols[0].name = "x1"
	cols[0].set_bounds(Rglpk::GLP_LO, 0.0, 0.0)
	cols[1].name = "x2"
	cols[1].set_bounds(Rglpk::GLP_LO, 0.0, 0.0)
	cols[2].name = "x3"
	cols[2].set_bounds(Rglpk::GLP_LO, 0.0, 0.0)

	p.obj.coefs = [10, 6, 4]

	p.set_matrix([
	 1, 1, 1,
	10, 4, 5,
	 2, 2, 6
	])

	p.simplex
	z = p.obj.get
	x1 = cols[0].get_prim
	x2 = cols[1].get_prim
	x3 = cols[2].get_prim

	printf("z = %g; x1 = %g; x2 = %g; x3 = %g\n", z, x1, x2, x3)
	#=> z = 733.333; x1 = 33.3333; x2 = 66.6667; x3 = 0

# Testing

Test everything with:

	> rake test

Test a specific test with:

	> ruby test/test_brief_example.rb # or what have you.

# License

Copyright (C) 2007 Alex Gutteridge

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
