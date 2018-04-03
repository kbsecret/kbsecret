# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Cp
class KBSecretCommandCpTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_cp_help
    cp_helps = [
      %w[cp --help],
      %w[cp -h],
      %w[help cp],
    ]

    cp_helps.each do |cp_help|
      stdout, = kbsecret(*cp_help)
      assert_match "Usage:", stdout
    end
  end

  def test_cp_too_few_arguments
    tfas = [
      %w[cp],
      %w[cp default],
      %w[cp default default],
    ]

    tfas.each do |tfa|
      _, stderr = kbsecret(*tfa)

      assert_match "Too few arguments given", stderr
    end
  end

  def test_cp_fails_on_same_session
    kbsecret "new", "login", "test-cp-same-session", input: "foo\nbar\n"

    # we need -f here, since it'll fail earlier on overwrite without force
    _, stderr = kbsecret "cp", "default", "default", "test-cp-same-session", "-f"

    assert_match "Session 'default' cannot import records from itself", stderr
  ensure
    kbsecret "rm", "test-cp-same-session"
  end

  def test_cp_no_such_records
    skip
  end

  def test_cp_fails_on_nonexistent_session
    skip
  end

  def test_cp_copy
    kbsecret "new", "login", "test-cp-copy", input: "foo\nbar\n"
    kbsecret "session", "new", "cp-test-session", "-r", "cp-test-session"

    # the record isn't in the dest session yet, but is in the source session
    refute KBSecret::Session["cp-test-session"].record?("test-cp-copy")
    assert KBSecret::Session[:default].record?("test-cp-copy")

    kbsecret "cp", "default", "cp-test-session", "test-cp-copy"

    # the record is now in both sessions
    assert KBSecret::Session["cp-test-session"].record?("test-cp-copy")
    assert KBSecret::Session[:default].record?("test-cp-copy")
  ensure
    kbsecret "rm", "test-cp-copy"
    kbsecret "session", "rm", "-d", "cp-test-session"
  end

  def test_cp_copy_multiple
    skip
  end

  def test_cp_move
    kbsecret "new", "login", "test-cp-move", input: "foo\nbar\n"
    kbsecret "session", "new", "cp-test-move-session", "-r", "cp-test-move-session"

    # the record isn't in the dest session yet, but is in the source session
    refute KBSecret::Session["cp-test-move-session"].record?("test-cp-move")
    assert KBSecret::Session[:default].record?("test-cp-move")

    kbsecret "cp", "-m", "default", "cp-test-move-session", "test-cp-move"

    assert KBSecret::Session["cp-test-move-session"].record?("test-cp-move")
    refute KBSecret::Session[:default].record?("test-cp-move")
  ensure
    kbsecret "rm", "test-cp-move"
    kbsecret "session", "rm", "-d", "cp-test-move-session"
  end

  def test_cp_move_multiple
    skip
  end

  def test_cp_fails_on_overwrite
    kbsecret "new", "login", "test-cp-overwrite", input: "foo\nbar\n"

    _, stderr = kbsecret "cp", "default", "default", "test-cp-overwrite"

    assert_match "Refusing to overwrite existing record(s) without --force", stderr
  ensure
    kbsecret "rm", "test-cp-overwrite"
  end

  def test_cp_force_overwrite
    skip
  end
end
