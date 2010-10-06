require 'rake/clean'

# Copied from hoe.
def paragraphs_of(path, *paragraphs)
  File.read(path).split(/\n\n+/).values_at(*paragraphs)
end

def in_dir(path)
  original_dir = Dir.pwd
  Dir.chdir(path)
  yield
ensure
  Dir.chdir(original_dir)
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rglpk"
    gemspec.summary = paragraphs_of("README.txt", 1)[0]
    gemspec.description = paragraphs_of("README.txt", 1..3)[0]
    gemspec.homepage = "http://rglpk.rubyforge.org/"
    
    gemspec.authors = ["Alex Gutteridge", "William Taysom"]
    gemspec.email = ["alexg@kuicr.kyoto-u.ac.jp", "wtaysom@gmail.com"]
    
    gemspec.extensions << 'ext/extconf.rb'
    gemspec.require_paths << 'ext'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end


SHARED_LIBRARY_EXTENSION = RUBY_PLATFORM.include?("darwin") ? 'bundle' : 'so'
EXTENSION = 'ext/rglpk.'+SHARED_LIBRARY_EXTENSION

desc "Use extconf.rb and make to build the extension."
task :build_extension => EXTENSION

file EXTENSION => 'ext/rglpk.c' do
  in_dir('ext') do
    system("ruby extconf.rb")
    system("make")
  end
end

CLEAN.include('ext/Makefile', 'ext/conftest.dSYM', 'ext/mkmf.log', 
  'ext/rglpk.bundle', 'ext/rglpk.o')

file 'ext/rglpk.c' => 'swig/glpk.i' do
  in_dir('swig') do
    system("autoconf")
    system("configure")
    system("make wrap")
  end
end

CLEAN.include('swig/Makefile', 'swig/autom4te.cache', 'swig/config.log',
  'swig/config.status', 'swig/configure', 'swig/rglpk.c')

CLOBBER.include('ext/rglpk.c')

desc "Run Test::Unit tests."
task :test => :build_extension do
  system("ruby test/test_all.rb")
end