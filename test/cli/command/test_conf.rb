# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Conf
class KBSecretCommandConfTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_conf_help
    conf_helps = [
      %w[conf --help],
      %w[conf -h],
      %w[help conf],
    ]

    conf_helps.each do |conf_help|
      stdout, = kbsecret(*conf_help)
      assert_match(/Usage:/, stdout)
    end
  end

  def test_conf_fails_without_editor
    old_editor = ENV["EDITOR"]
    ENV.delete("EDITOR")

    _, stderr = kbsecret "conf"

    assert_match(/Missing \$EDITOR/, stderr)

    _, stderr = kbsecret "conf", "-c"

    assert_match(/Missing \$EDITOR/, stderr)
  ensure
    ENV["EDITOR"] = old_editor
  end

  def test_conf_opens_config
    # this test no longer works because we do fork in the test suite + exec in `conf`,
    # clobbering I/O in the process
    skip
    with_env("EDITOR" => "cat") do
      stdout, = kbsecret "conf"

      assert_match(/:mount:/, stdout)
    end
  end

  def test_conf_opens_command_config
    # this test no longer works because we do fork in the test suite + exec in `conf`,
    # clobbering I/O in the process
    skip
    # commands.ini's contents are empty by default, so put some junk in it
    # for testing purposes
    File.write(KBSecret::Config::COMMAND_CONFIG_FILE, "[foo]\nargs = --bar")

    with_env("EDITOR" => "cat") do
      stdout, = kbsecret "conf", "-c"

      assert_match(/\[foo\]\nargs = --bar/, stdout)
    end
  ensure
    FileUtils.rm_rf KBSecret::Config::COMMAND_CONFIG_FILE
  end

  def test_conf_emits_conf_dir
    with_env("EDITOR" => "cat") do
      stdout, = kbsecret "conf", "-d"

      assert_match KBSecret::Config::CONFIG_DIR, stdout
    end
  end

  def test_conf_emits_record_dir
    with_env("EDITOR" => "cat") do
      stdout, = kbsecret "conf", "-r"

      assert_match KBSecret::Config::CUSTOM_TYPES_DIR, stdout
    end
  end
end
