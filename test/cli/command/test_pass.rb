# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Pass
class KBSecretCommandPassTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_pass_help
    pass_helps = [
      %w[help --help],
      %w[help -h],
      %w[help help],
    ]

    pass_helps.each do |pass_help|
      stdout, = kbsecret(*pass_help)
      assert_match(/Usage:/, stdout)
    end
  end

  def test_pass_too_few_arguments
    _, stderr = kbsecret "pass"

    assert_match(/Too few arguments given/, stderr)
  end

  def test_pass_no_such_login_record
    _, stderr = kbsecret "pass", "this_record_really_should_not_exist"

    assert_match(/No such login record/, stderr)

    # pass filters for login records, so passing it a non-login record should fail
    kbsecret "new", "environment", "test-pass-with-env", input: "key\nvalue\n"
    _, stderr = kbsecret "pass", "test-pass-with-env"

    assert_match(/No such login record/, stderr)
  ensure
    kbsecret "rm", "test-pass-with-env"
  end

  def test_pass_outputs_password
    kbsecret "new", "login", "test-pass-outputs-password", input: "foo\nbar\n"

    stdout, = kbsecret "pass", "test-pass-outputs-password"

    assert_match(/bar/, stdout)
  ensure
    kbsecret "rm", "test-pass-outputs-password"
  end

  def test_pass_clips_password
    # XXX: figure out how to mock the clipboard in unit tests
    skip
  end

  def test_pass_accepts_session
    session_label = "pass-test-session"

    kbsecret "session", "new", session_label, "-r", session_label

    # N.B. we need to call this because the prior `session` call only updates `Config`
    # in its copy of the process.
    KBSecret::Config.load!

    kbsecret "new", "-s", session_label, "login", "test-pass-session", input: "foo\nbar\n"

    stdout, = kbsecret "pass", "-s", session_label, "test-pass-session"

    assert_match(/bar/, stdout)
  ensure
    kbsecret "session", "rm", "-d", session_label
  end
end
