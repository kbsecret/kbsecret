# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Commands
class KBSecretCommandCommandsTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_commands_help
    commands_helps = [
      %w[commands --help],
      %w[commands -h],
      %w[help commands],
    ]

    commands_helps.each do |commands_help|
      stdout, = kbsecret(*commands_help)
      assert_match(/Usage:/, stdout)
    end
  end

  def test_commands_lists_all_commands
    stdout, = kbsecret "commands"

    stdout.lines.each do |command|
      command.chomp!
      assert KBSecret::CLI::Command.all_command_names.include?(command)
    end
  end

  def test_commands_lists_all_external_commands
    stdout, = kbsecret "commands", "-e"

    stdout.lines.each do |command|
      command.chomp!
      assert KBSecret::CLI::Command.external?(command)
    end
  end

  def test_commands_lists_all_internal_commands
    stdout, = kbsecret "commands", "-i"

    stdout.lines.each do |command|
      command.chomp!
      assert KBSecret::CLI::Command.internal?(command)
    end
  end
end
