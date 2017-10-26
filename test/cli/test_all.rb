# frozen_string_literal: true

# NOTE: run the test suite with: $ bundle exec ruby -I lib:test test/cli/test_all.rb -v
require_relative "test_kbsecret"
require_relative "test_new"
require_relative "test_login"
require_relative "test_env"
require_relative "test_todo"
require_relative "test_dump_fields"
require_relative "test_generators"
require_relative "test_generator"
require_relative "test_list"
