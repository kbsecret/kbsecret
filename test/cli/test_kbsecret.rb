# frozen_string_literal: true

require "helpers"

# tests cli commands: built-in (help, version, commands, types, & conf)
class CLIBuiltinsTest < Minitest::Test
  include Aruba::Api
  include Helpers

  def setup
    setup_aruba
  end

  def test_help
    # `kbsecret help` should always run, and should produce a "Usage:" output
    run_command "kbsecret help" do |cmd|
      cmd.wait
      assert_match(/Usage/, cmd.stdout)
    end
  end

  def test_version
    exp = "kbsecret version #{KBSecret::VERSION}."

    # `kbsecret version` should always run, and should produce KBSecret's current version
    run_command "kbsecret version" do |cmd|
      cmd.wait
      assert_equal exp, cmd.output.chomp
    end
  end

  def test_commands
    # `kbsecret commands` should always run
    run_command_and_stop "kbsecret commands"
  end

  def test_types
    # `kbsecret types` should always run, and should produce every type known to KBSecret
    run_command "kbsecret types" do |cmd|
      cmd.wait
      KBSecret::Record.record_types.each do |type|
        assert_includes cmd.output, type.to_s
      end
    end
  end

  def test_conf
    # with EDITOR unset, `kbsecret conf` should produce an error message
    delete_environment_variable "EDITOR"
    run_command "kbsecret conf" do |cmd|
      cmd.wait
      assert_match(/You need to set \$EDITOR/, cmd.stderr)
    end

    # with EDITOR set to `cat`, `kbsecret conf` should output the configuration
    set_environment_variable "EDITOR", "cat"
    run_command "kbsecret conf" do |cmd|
      cmd.wait
      assert_match(/:mount:/, cmd.output)
    end
  end
end
