# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib")

require "rake/testtask"

desc "Run unit tests"
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
end

desc "Run CLI unit tests"
Rake::TestTask.new(:"test-cli") do |t|
  t.libs << "test"
  t.test_files = FileList["test/cli/test_*.rb"]
end

task default: :test
