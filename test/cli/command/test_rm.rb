# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Rm
class KBSecretCommandRmTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_rm_help
    rm_helps = [
      %w[rm --help],
      %w[rm -h],
      %w[help rm],
    ]

    rm_helps.each do |rm_help|
      stdout, = kbsecret(*rm_help)
      assert_match "Usage:", stdout
    end
  end

  def test_rm_too_few_arguments
    _, stderr = kbsecret "rm"

    assert_match "Too few arguments given", stderr
  end

  def test_rm_no_such_record
    _, stderr = kbsecret "rm", "this-does-not-exist"

    assert_match "No such record(s)", stderr
  end

  def test_rm_single
    kbsecret "new", "login", "test-rm-single", input: "foo\nbar\n"

    assert KBSecret::Session[:default].record?("test-rm-single")

    kbsecret "rm", "test-rm-single"

    refute KBSecret::Session[:default].record?("test-rm-single")
  end

  def test_rm_multiple
    kbsecret "new", "login", "test-rm-multi1", input: "foo\nbar\n"
    kbsecret "new", "login", "test-rm-multi2", input: "baz\nquux\n"

    assert KBSecret::Session[:default].record?("test-rm-multi1")
    assert KBSecret::Session[:default].record?("test-rm-multi2")

    kbsecret "rm", "test-rm-multi1", "test-rm-multi2"

    refute KBSecret::Session[:default].record?("test-rm-multi1")
    refute KBSecret::Session[:default].record?("test-rm-multi2")
  end

  def test_rm_interactive
    kbsecret "new", "login", "test-rm-interactive", input: "foo\nbar\n"

    assert KBSecret::Session[:default].record?("test-rm-interactive")

    kbsecret "rm", "-i", "test-rm-interactive", input: "y"

    refute KBSecret::Session[:default].record?("test-rm-interactive")
  end

  def test_rm_accepts_session
    kbsecret "session", "new", "rm-test-session", "-r", "rm-test-session"
    kbsecret "new", "login", "-s", "rm-test-session", "test-rm-session", input: "foo\nbar\n"

    assert KBSecret::Session["rm-test-session"].record?("test-rm-session")

    kbsecret "rm", "-s", "rm-test-session", "test-rm-session"

    refute KBSecret::Session["rm-test-session"].record?("test-rm-session")
  ensure
    kbsecret "session", "rm", "-d", "rm-test-session"
  end
end
