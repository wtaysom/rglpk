# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: rglpk 0.4.0 ruby lib
# stub: ext/extconf.rb ext/extconf.rb

Gem::Specification.new do |s|
  s.name = "rglpk"
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Alex Gutteridge", "William Taysom"]
  s.date = "2015-05-17"
  s.description = "# Introduction\n\nRglpk is a package providing a Ruby wrapper to the [GNU GLPK](http://www.gnu.org/software/glpk/) library.  The GLPK (GNU Linear Programming Kit) package is intended for solving large-scale linear programming (LP), mixed integer programming (MIP), and other related problems.\n\nRglpk (pronounced as \"wriggle-pick\") is currently in alpha status and the API should be considered subject to change.  Rglpk uses [Swig](http://www.swig.org/) to initially wrap the C GLPK library (using a Swig wrapper originally developed by Nigel Galloway) and then a pure Ruby library to wrap the Swig code in a more friendly OO-style."
  s.email = ["alexg@kuicr.kyoto-u.ac.jp", "wtaysom@gmail.com"]
  s.extensions = ["ext/extconf.rb", "ext/extconf.rb"]
  s.extra_rdoc_files = [
    "ChangeLog.md",
    "README.md"
  ]
  s.files = [
    ".travis.yml",
    "ChangeLog.md",
    "Gemfile",
    "Gemfile.lock",
    "License.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "ext/extconf.rb",
    "ext/glpk_wrapper.c",
    "lib/rglpk.rb",
    "rglpk.gemspec",
    "swig/Makefile.in",
    "swig/configure.in",
    "swig/glpk.i",
    "test/helper.rb",
    "test/test_all.rb",
    "test/test_basic.rb",
    "test/test_brief_example.rb",
    "test/test_memory_leaks.rb",
    "test/test_problem_kind.rb"
  ]
  s.homepage = "http://rglpk.rubyforge.org/"
  s.rdoc_options = ["--exclude", "."]
  s.rubyforge_project = "rglpk"
  s.rubygems_version = "2.4.6"
  s.summary = "# Introduction"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end

