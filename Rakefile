require 'rubygems'
require 'rake/testtask'

#
# Documents
#
require 'rdoc/task'

Rake::RDocTask.new(:rdoc) do |rd|
  rd.rdoc_dir = 'rdoc'
  rd.title = 'gtoc'
  rd.options << '--line-numbers' << '--inline-source' << '--charset=UTF-8'
  rd.rdoc_files.include('MIT-LICENSE')
  rd.rdoc_files.include('lib/**/*.rb')
end
task :default => :rdoc
