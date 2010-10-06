== Introduction

Rglpk is a package providing a Ruby wrapper to the GNU glpk library (http://www.gnu.org/software/glpk/). The GLPK (GNU Linear Programming Kit) package is intended for solving large-scale linear programming (LP), mixed integer programming (MIP), and other related problems.

Rglpk is currently in alpha status and the API should be considered subject to change. The main documentation can be found at http://rglpk.rubyforge.org/. Rglpk uses Swig to initially wrap the C GLPK library (using a Swig wrapper originally developed by Nigel Galloway) and then a pure Ruby library to wrap the Swig code in a more friendly OO-style.

All bug reports, feature requests and patches are welcome. Please email alexg (at) kuicr.kyoto-u.ac.jp or use the rubyforge forums: http://rubyforge.org/forum/?group_id=3943

== Installation

A working glpk library installation is required.

Rglpk is only available as a gem. For example, under Ubuntu linux the following command succesfully compiles and installs (you may need to be root):

  gem install rglpk

The underlying C library is wrapped using Swig. See /swig for details on the interface.

== Documentation

Rglpk provides two files: rglpk.so which is a Swig generated wrapper and glpk.rb which wraps rglpk.so to provide a nicer OO-orientated interface. You should only ever need to access glpk.rb.

An example:

  require 'glpk'

  #Yadda yadda

== License

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
