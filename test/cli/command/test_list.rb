# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::List
class KBSecretCommandListTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_list_help
    list_helps = [
      %w[list --help],
      %w[list -h],
    ]

    list_helps.each do |list_help|
      stdout, = kbsecret(*list_help)
      assert_match(/Usage:/, stdout)
    end
  end

  def test_list_contains_record
    kbsecret "new", "login", "test-list", input: "foo\nbar\n"

    stdout, = kbsecret "list"

    assert_includes stdout.split, "test-list"
  ensure
    kbsecret "rm", "test-list"
  end

  def test_list_filters_by_type
    kbsecret "new", "login", "test-list1", input: "foo\nbar\n"
    kbsecret "new", "environment", "test-list2", input: "baz\nquux\n"

    stdout, = kbsecret "list", "-t", "environment"

    refute_includes stdout.split, "test-list1"
    assert_includes stdout.split, "test-list2"
  ensure
    kbsecret "rm", "test-list1", "test-list2"
  end

  def test_list_shows_all
    kbsecret "new", "login", "test-list", input: "foo\nbar\n"

    stdout, = kbsecret "list", "-a"
    assert_match(/Raw data:.*foo.*bar/, stdout)
  ensure
    kbsecret "rm", "test-list"
  end

  def test_list_accepts_session
    skip # flaky
    session_label = "list-test-session"

    kbsecret "session", "new", session_label, "-r", session_label
    kbsecret "new", "-s", session_label, "login", "test-list", input: "foo\nbar\n"

    stdout, = kbsecret "list", "-s", session_label
    assert_includes stdout.split, "test-list"
  ensure
    kbsecret "session", "rm", "-d", session_label
  end
end
