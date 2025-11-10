# frozen_string_literal: true

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
  t.warning = false
end

task default: :test

desc "Run RuboCop"
task :rubocop do
  sh "rubocop"
end

desc "Run RuboCop with auto-correct"
task "rubocop:autocorrect" do
  sh "rubocop -A"
end

desc "Run all tests and linters"
task all: [:test, :rubocop]

desc "Run console with loaded environment"
task :console do
  require_relative "lib/sqa"
  require "irb"
  ARGV.clear
  IRB.start
end
