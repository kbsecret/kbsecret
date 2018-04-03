# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::StashFile
class KBSecretCommandStashFileTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_stash_file_help
    stash_file_helps = [
      %w[stash-file --help],
      %w[stash-file -h],
      %w[help stash-file],
    ]

    stash_file_helps.each do |stash_file_help|
      stdout, = kbsecret(*stash_file_help)
      assert_match "Usage:", stdout
    end
  end

  def test_raw_edit_too_few_arguments
    _, stderr = kbsecret "stash-file"

    assert_match "Too few arguments given", stderr
  end

  def test_raw_edit_no_such_file
    _, stderr = kbsecret "stash-file", "test-stash-file-no-record", "/this/file/does/not/exist"

    assert_match "No such file", stderr

    refute KBSecret::Session[:default].record?("test-stash-file-no-record")
  end

  def test_stash_file_stores_plain_text
    kbsecret "stash-file", "test-stash-plain-text", "/etc/hostname"

    assert KBSecret::Session[:default].record?("test-stash-plain-text")

    stdout, = kbsecret "dump-fields", "test-stash-plain-text"

    assert_match File.read("/etc/hostname"), stdout
  ensure
    kbsecret "rm", "test-stash-plain-text"
  end

  def test_stash_file_stores_stdin
    kbsecret "stash-file", "test-stash-stdin", "-", input: "hello world!"

    assert KBSecret::Session[:default].record?("test-stash-stdin")

    stdout, = kbsecret "dump-fields", "test-stash-stdin"

    assert_match "hello world!", stdout
  ensure
    kbsecret "rm", "test-stash-stdin"
  end

  def test_stash_file_stores_base64
    kbsecret "stash-file", "test-stash-base64", "-b", "/etc/hostname"

    assert KBSecret::Session[:default].record?("test-stash-base64")

    stdout, = kbsecret "dump-fields", "test-stash-base64"

    assert_match File.read("/etc/hostname"), Base64.decode64(stdout)
  ensure
    kbsecret "rm", "test-stash-base64"
  end

  def test_stash_file_fails_on_overwrite
    kbsecret "stash-file", "test-stash-overwrite-fail", "/etc/hostname"

    record = KBSecret::Session[:default]["test-stash-overwrite-fail"]

    assert_equal File.read("/etc/hostname"), record.text

    _, stderr = kbsecret "stash-file", "test-stash-overwrite-fail", "-", input: "foobar"

    assert_match "Refusing to overwrite a record without --force", stderr
    assert_equal File.read("/etc/hostname"), record.text
  ensure
    kbsecret "rm", "test-stash-overwrite-fail"
  end

  def test_stash_file_force_overwrite
    kbsecret "stash-file", "test-stash-force-overwrite", "-", input: "foobar"

    stdout, = kbsecret "dump-fields", "test-stash-force-overwrite"

    assert_match "foobar", stdout

    kbsecret "stash-file", "test-stash-force-overwrite", "-f", "-", input: "bazquux"

    stdout, = kbsecret "dump-fields", "test-stash-force-overwrite"

    assert_match "bazquux", stdout
  ensure
    kbsecret "rm", "test-stash-force-overwrite"
  end

  def test_stash_file_accepts_session
    session_label = "stash-file-test-session"

    kbsecret "session", "new", session_label, "-r", session_label

    kbsecret "stash-file", "-s", session_label, "test-stash-file-session", "/etc/hostname"

    stdout, = kbsecret "dump-fields", "-s", session_label, "test-stash-file-session"

    assert_match File.read("/etc/hostname"), stdout
  ensure
    kbsecret "session", "rm", "-d", session_label
  end
end
