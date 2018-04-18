# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Session
class KBSecretCommandSessionTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_session_help
    session_helps = [
      %w[session --help],
      %w[session -h],
      %w[help session],
    ]

    session_helps.each do |session_help|
      stdout, = kbsecret(*session_help)
      assert_match "Usage:", stdout
    end
  end

  def test_session_too_few_arguments
    _, stderr = kbsecret "session"

    assert_match "Too few arguments given", stderr

    _, stderr = kbsecret "session", "new"

    assert_match "Too few arguments given", stderr
  end

  def test_session_unknown_subcommand
    _, stderr = kbsecret "session", "made-up-subcommand", "whatever"

    assert_match "Unknown subcommand", stderr
  end

  def test_session_new_fails_on_overwrite
    kbsecret "session", "new", "test-session-overwrite", "-r", "test-session-overwrite"

    _, stderr = kbsecret "session", "new", "test-session-overwrite", "-r", "test-session-overwrite"

    assert_match "Refusing to overwrite a session without --force", stderr
  ensure
    kbsecret "session", "rm", "-d", "test-session-overwrite"
  end

  def test_session_new_force_overwrite
    kbsecret "session", "new", "test-session-force-overwrite", "-r", "root1"
    kbsecret "session", "new", "test-session-force-overwrite", "-r", "root2", "-f"

    assert_match "root2", KBSecret::Session["test-session-force-overwrite"].path
  ensure
    kbsecret "session", "rm", "-d", "test-session-force-overwrite"
  end

  def test_session_new_single_user
    kbsecret "session", "new", "test-session-new-single", "-r", "test-session-new-single"

    assert KBSecret::Config.session?("test-session-new-single")

    conf = KBSecret::Config.session("test-session-new-single")

    assert_equal conf[:root], "test-session-new-single"
    assert_equal conf[:users].size, 1
  ensure
    kbsecret "session", "rm", "-d", "test-session-new-single"
  end

  def test_session_new_multi_user
    skip
  end

  def test_session_new_team
    skip
  end

  def test_session_rm
    kbsecret "session", "new", "test-session-rm", "-r", "test-session-rm"

    assert KBSecret::Config.session?("test-session-rm")

    session_path = KBSecret::Session["test-session-rm"].path

    kbsecret "session", "rm", "test-session-rm"

    # Without -d, the session is removed but *not* deleted from disk.
    refute KBSecret::Config.session?("test-session-rm")
    assert Dir.exist?(session_path)
  ensure
    FileUtils.rm_rf session_path if session_path
  end

  def test_session_rm_and_unlink
    kbsecret "session", "new", "test-session-rm-unlink", "-r", "test-session-rm-unlink"

    assert KBSecret::Config.session?("test-session-rm-unlink")

    session_path = KBSecret::Session["test-session-rm-unlink"].path

    kbsecret "session", "rm", "-d", "test-session-rm-unlink"

    # With -d, the session is both removed *and* deleted from disk.
    refute KBSecret::Config.session?("test-session-rm-unlink")
    refute Dir.exist?(session_path)
  end
end
