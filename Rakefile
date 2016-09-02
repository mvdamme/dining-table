# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  if ENV['ENV'] == 'test'
    Bundler.setup(:test)
  else
    Bundler.setup(:default, :development)
  end
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'juwelier'
Juwelier::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "dining-table"
  gem.homepage = "http://github.com/mvdamme/dining-table"
  gem.license = "MIT"
  gem.summary = %Q{Create tables easily. Supports html, csv and xlsx.}
  gem.description = %Q{Easily output tabular data, be it in HTML, CSV or XLSX. Create clean table classes instead of messing with views to create nice tables.}
  gem.email = "michael.vandamme@vub.ac.be"
  gem.authors = ["Micha\u{eb}l Van Damme"]
  # dependencies defined in Gemfile
end
Juwelier::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'spec'
  test.pattern = 'spec/**/*_spec.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "dining-table #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
