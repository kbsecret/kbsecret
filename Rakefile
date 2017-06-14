# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib")

require "rake/testtask"

Rake::TestTask.new { |t| t.libs << "test" }

desc "Run tests"
task default: :test
