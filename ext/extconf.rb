require 'mkmf'
dir_config('glpk')
unless have_library("glpk")
  $stderr.puts "\nERROR: Cannot find the GLPK library, aborting."
  exit 1
end
unless have_header("glpk.h")
  $stderr.puts "\nERROR: Cannot find the GLPK header, aborting."
  exit 1
end
  
create_makefile('glpk_wrapper')
