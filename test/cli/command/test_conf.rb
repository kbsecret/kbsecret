# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Conf
class KBSecretCommandConfTest < Minitest::Test
  include Helpers
  include Helpers::CLI

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
