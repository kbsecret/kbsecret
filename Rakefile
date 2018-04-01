# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib")

require "rake/testtask"

desc "Run unit tests"
Rake::TestTask.new(:test) do |t|
  t.libs = %w[lib test]
  t.pattern = "test/**/test_*.rb"
end

desc "Upload coverage to codecov"
task :codecov do
  require "simplecov"
  require "codecov"

  formatter = SimpleCov::Formatter::Codecov.new
  formatter.format(SimpleCov::ResultMerger.merged_result)
end

task default: :test
