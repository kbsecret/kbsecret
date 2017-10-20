# frozen_string_literal: true

require_relative "test_helper"

class CLIBuiltinsTest < Minitest::Test
  include Aruba::Api
  include Helpers

  def setup
    setup_aruba
  end

  def test_help
    run_command_and_stop "kbsecret help"
    assert_match(/Usage:/, last_command_started.output.chomp)
  end

  def test_version
    version_string = "kbsecret version #{KBSecret::VERSION}."
    run_command_and_stop "kbsecret version"
    assert_equal version_string, last_command_started.output.chomp
  end

  def test_commands
    run_command_and_stop "kbsecret commands"
  end

  def test_types
    run_command_and_stop "kbsecret types"

    KBSecret::Record.record_types.each do |type|
      assert_includes last_command_started.output.chomp, type.to_s
    end
  end

  def test_conf
    # NOTE: assumes availability of bash shell
    run_command "bash -c 'unset EDITOR && kbsecret conf'"
    stop_all_commands
    assert_match(/You need to set \$EDITOR/, last_command_started.stderr.chomp)

    run_command_and_stop "bash -c 'EDITOR=cat && kbsecret conf'"
    assert_match(/:mount:/, last_command_started.output.chomp)
  end
end
