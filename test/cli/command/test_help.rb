# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Help
class KBSecretCommandHelpTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_help_help
    help_helps = [
      %w[help --help],
      %w[help -h],
      %w[help help],
    ]

    help_helps.each do |help_help|
      stdout, = kbsecret(*help_help)
      assert_match(/Usage:/, stdout)
    end
  end

  def test_help_toplevel_output
    stdout, = kbsecret "help"

    assert_match(/Usage:/, stdout)
    assert_match(/Available commands:/, stdout)
  end

  def test_help_internal_command
    stdout, = kbsecret "help", "list"

    assert_match(/Usage:/, stdout)
  end

  def test_help_external_command
    # XXX: not sure how to do this yet.
    skip
  end

  def test_help_unknown_command
    _, stderr = kbsecret "help", "this-is-a-command-that-should-not-exist"

    assert_match(/Unknown command/, stderr)
  end
end
