require 'hoe'

$LOAD_PATH.unshift("./ext")

module GLPK
  VERSION = "0.1"
end

begin 
  require 'glpk'
rescue RuntimeError
end

hoe = Hoe.new("rglpk",GLPK::VERSION) do |p|
  
  p.author = "Alex Gutteridge"
  p.email = "alexg@kuicr.kyoto-u.ac.jp"
  p.url = "http://rglpk.rubyforge.org/"
  
  p.description = p.paragraphs_of("README.txt",1..3)[0]
  p.summary     = p.paragraphs_of("README.txt",1)[0]
  p.changes     = p.paragraphs_of("History.txt",0..1).join("\n\n")
  
  p.clean_globs = ["ext/*.o","ext/*.so","ext/Makefile","ext/mkmf.log","**/*~","email.txt"]
  
  p.rdoc_pattern = /(^ext\/.*\.c$|^README|^History|^License)/
  
  p.spec_extras = {
    :extensions    => ['ext/extconf.rb'],
    :require_paths => ['test'],
    :has_rdoc      => true,
    :extra_rdoc_files => ["README.txt","History.txt","License.txt"],
    :rdoc_options  => ["--exclude", "test/*", "--main", "README.txt", "--inline-source"]
  }

end
  
hoe.spec.dependencies.delete_if{|dep| dep.name == "hoe"}

desc "Uses extconf.rb and make to build the extension"
task :build_extension => ['ext/rglpk.so']
SRC = FileList['ext/rglpk.c']
file 'ext/rglpk.so' => SRC do
  Dir.chdir('ext')
  system("ruby extconf.rb")
  system("make")
  Dir.chdir('..')
end

task :test => [:build_extension]
