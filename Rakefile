# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib")

require "rake/testtask"

desc "Run unit tests"
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
end

task default: :test
