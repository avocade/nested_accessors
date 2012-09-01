#!/usr/bin/env rake
require "bundler/gem_tasks"

task default: :test

require 'rake/testtask'
Rake::TestTask.new do |i|
  i.test_files = FileList['spec/*_spec.rb']
  i.verbose = true
end
