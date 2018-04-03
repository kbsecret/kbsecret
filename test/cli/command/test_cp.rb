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

  def test_cp_no_such_record
    kbsecret "session", "new", "cp-test-no-such-records", "-r", "cp-test-no-such-records"

    _, stderr = kbsecret "cp", "cp-test-no-such-records", "default", "this-does-not-exist"

    assert_match "No such record(s)", stderr
  ensure
    kbsecret "session", "rm", "-d", "cp-test-no-such-records"
  end

  def test_cp_fails_on_nonexistent_session
    _, stderr = kbsecret "cp", "cp-test-nonexistent-session", "default", "whatever"

    assert_match "Unknown session", stderr

    _, stderr = kbsecret "cp", "default", "cp-test-nonexistent-session", "whatever"

    assert_match "Unknown session", stderr
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
    kbsecret "new", "login", "test-cp-copy-multi1", input: "foo\nbar\n"
    kbsecret "new", "login", "test-cp-copy-multi2", input: "baz\nquux\n"
    kbsecret "session", "new", "cp-test-session-multi", "-r", "cp-test-session-multi"

    # the records aren't in the dest session yet, but are in the source session
    assert KBSecret::Session[:default].record?("test-cp-copy-multi2")
    assert KBSecret::Session[:default].record?("test-cp-copy-multi2")
    refute KBSecret::Session["cp-test-session-multi"].record?("test-cp-copy-multi1")
    refute KBSecret::Session["cp-test-session-multi"].record?("test-cp-copy-multi1")

    kbsecret "cp", "default", "cp-test-session-multi", "test-cp-copy-multi1", "test-cp-copy-multi2"

    # the records are now in both sessions
    assert KBSecret::Session[:default].record?("test-cp-copy-multi2")
    assert KBSecret::Session[:default].record?("test-cp-copy-multi2")
    assert KBSecret::Session["cp-test-session-multi"].record?("test-cp-copy-multi1")
    assert KBSecret::Session["cp-test-session-multi"].record?("test-cp-copy-multi1")
  ensure
    kbsecret "rm", "test-cp-copy-multi1", "test-cp-copy-multi2"
    kbsecret "session", "rm", "-d", "cp-test-session-multi"
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
    kbsecret "new", "login", "test-cp-move-multi1", input: "foo\nbar\n"
    kbsecret "new", "login", "test-cp-move-multi2", input: "baz\nquux\n"
    kbsecret "session", "new", "cp-test-session-multi", "-r", "cp-test-session-multi"

    # the records aren't in the dest session yet, but are in the source session
    assert KBSecret::Session[:default].record?("test-cp-move-multi2")
    assert KBSecret::Session[:default].record?("test-cp-move-multi2")
    refute KBSecret::Session["cp-test-session-multi"].record?("test-cp-move-multi1")
    refute KBSecret::Session["cp-test-session-multi"].record?("test-cp-move-multi1")

    kbsecret "cp", "-m", "default", "cp-test-session-multi", "test-cp-move-multi1", "test-cp-move-multi2"

    # the records are now in the dest session, and no longer in the source
    refute KBSecret::Session[:default].record?("test-cp-move-multi2")
    refute KBSecret::Session[:default].record?("test-cp-move-multi2")
    assert KBSecret::Session["cp-test-session-multi"].record?("test-cp-move-multi1")
    assert KBSecret::Session["cp-test-session-multi"].record?("test-cp-move-multi1")
  ensure
    kbsecret "rm", "test-cp-move-multi1", "test-cp-move-multi2"
    kbsecret "session", "rm", "-d", "cp-test-session-multi"
  end

  def test_cp_fails_on_overwrite
    kbsecret "new", "login", "test-cp-overwrite", input: "foo\nbar\n"

    _, stderr = kbsecret "cp", "default", "default", "test-cp-overwrite"

    assert_match "Refusing to overwrite existing record(s) without --force", stderr
  ensure
    kbsecret "rm", "test-cp-overwrite"
  end

  def test_cp_force_overwrite
    kbsecret "session", "new", "cp-test-session-overwrite", "-r", "cp-test-session-overwrite"
    kbsecret "new", "login", "test-cp-force-overwrite", input: "foo\nbar\n"
    kbsecret "new", "-s", "cp-test-session-overwrite", "login", "test-cp-force-overwrite", input: "baz\nquux\n"

    login = KBSecret::Session[:default]["test-cp-force-overwrite"]

    assert_equal "foo", login.username
    assert_equal "bar", login.password

    kbsecret "cp", "-f", "cp-test-session-overwrite", "default", "test-cp-force-overwrite"

    login = KBSecret::Session[:default]["test-cp-force-overwrite"]

    assert_equal "baz", login.username
    assert_equal "quux", login.password
  ensure
    kbsecret "rm", "test-cp-force-overwrite"
    kbsecret "session", "rm", "-d", "cp-test-session-overwrite"
  end
end
