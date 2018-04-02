# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Env
class KBSecretCommandEnvTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_env_help
    env_helps = [
      %w[env --help],
      %w[env -h],
      %w[help env],
    ]

    env_helps.each do |env_help|
      stdout, = kbsecret(*env_help)
      assert_match(/Usage:/, stdout)
    end
  end

  def test_env_too_few_arguments
    _, stderr = kbsecret "env"

    assert_match(/Too few arguments given/, stderr)
  end

  def test_env_no_such_records
    _, stderr = kbsecret "login", "this_record_really_should_not_exist"

    assert_match(/No such record\(s\)/, stderr)

    # this should also fail, since `kbsecret env` filters for environment records only
    kbsecret "new", "login", "test-env-with-login", input: "foo\nbar\n"
    _, stderr = kbsecret "env", "test-env-with-login"

    assert_match(/No such record\(s\)/, stderr)
  ensure
    kbsecret "rm", "test-env-with-login"
  end

  def test_env_single_record
    kbsecret "new", "env", "test-env-single", input: "variable\nvalue\n"

    stdout, = kbsecret "env", "test-env-single"

    assert_match(/export variable=value/, stdout)

    stdout, = kbsecret "env", "-v", "test-env-single"

    assert_match(/^value/, stdout)

    stdout, = kbsecret "env", "-n", "test-env-single"

    assert_match(/^variable=value/, stdout)
  ensure
    kbsecret "rm", "test-env-single"
  end

  def test_login_multiple_records
    kbsecret "new", "env", "test-env-multi1", input: "variable\nvalue\n"
    kbsecret "new", "env", "test-env-multi2", input: "variable2\nvalue2\n"

    stdout, = kbsecret "env", "test-env-multi1", "test-env-multi2"

    # we expect the output to include both env records, in any order
    assert stdout.include?("export variable=value")
    assert stdout.include?("export variable2=value2")

    stdout, = kbsecret "env", "-n", "test-env-multi1", "test-env-multi2"

    # we expect multiple env records to be printed on one line, when using -n
    assert_equal 1, stdout.lines.size
    assert stdout.include?("variable=value")
    assert stdout.include?("variable2=value2")

    stdout, = kbsecret "env", "-v", "test-env-multi1", "test-env-multi2"

    # we expect one value per line, when using -v
    assert_equal 2, stdout.lines.size
    assert stdout.include?("value")
    assert stdout.include?("value2")
  ensure
    kbsecret "rm", "test-env-multi1", "test-env-multi2"
  end

  def test_env_all
    stdout, = kbsecret "env", "-a"

    assert_equal KBSecret::Session[:default].records(:environment).size, stdout.lines.size
  end

  def test_env_unescape_plus
    # XXX: test this
    skip
  end

  def test_env_accepts_session
    session_label = "env-test-session"

    kbsecret "session", "new", session_label, "-r", session_label

    # N.B. we need to call this because the prior `session` call only updates `Config`
    # in its copy of the process.
    KBSecret::Config.load!

    kbsecret "new", "-s", session_label, "environment", "test-env-session", input: "var\nval\n"

    stdout, = kbsecret "env", "-s", session_label, "test-env-session"

    assert_match(/export var=val/, stdout)
  ensure
    kbsecret "session", "rm", "-d", session_label
  end
end
