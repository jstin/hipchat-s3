require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "hipchat-s3"
    gem.summary = %Q{Ruby library to upload files to s3 and alert users in hipchat with a link}
    gem.description = %Q{Ruby library to upload files to s3 and alert users in hipchat with a link}
    gem.email = "jd@stinware.com"
    gem.homepage = "http://github.com/jstin/hipchat-s3"
    gem.authors = ["Justin"]
    gem.add_dependency "hipchat"
    gem.add_dependency "aws-s3"
    gem.add_development_dependency "rspec", "~> 2.0"
    gem.add_development_dependency "rr", "~> 1.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "hipchat-s3 #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
