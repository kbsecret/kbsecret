# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Types
class KBSecretCommandTypesTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_types_help
    types_helps = [
      %w[types --help],
      %w[types -h],
      %w[help types],
    ]

    types_helps.each do |types_help|
      stdout, = kbsecret(*types_help)
      assert_match(/Usage:/, stdout)
    end
  end

  def test_types_output
    stdout, = kbsecret "types"

    stdout.lines.each do |type|
      type.chomp!
      assert KBSecret::Record.type?(type)
    end
  end
end
