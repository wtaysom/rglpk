# Copied from hoe.
def paragraphs_of(path, *paragraphs)
  File.read(path).split(/\n\n+/).values_at(*paragraphs)
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
  Dir.chdir('ext')
  system("ruby extconf.rb")
  system("make")
  Dir.chdir('..')
end

desc "Run Test::Unit tests."
task :test => :build_extension do
  system("ruby test/test_all.rb")
end