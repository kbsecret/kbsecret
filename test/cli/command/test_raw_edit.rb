# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::RawEdit
class KBSecretCommandRawEditTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_raw_edit_help
    raw_edit_helps = [
      %w[raw-edit --help],
      %w[raw-edit -h],
      %w[help raw-edit],
    ]

    raw_edit_helps.each do |raw_edit_help|
      stdout, = kbsecret(*raw_edit_help)
      assert_match(/Usage:/, stdout)
    end
  end

  def test_raw_edit_too_few_arguments
    _, stderr = kbsecret "raw-edit"

    assert_match(/Too few arguments given/, stderr)
  end

  def test_raw_edit_fails_without_editor
    old_editor = ENV["EDITOR"]
    ENV.delete("EDITOR")

    kbsecret "new", "login", "test-raw-edit", input: "foo\nbar\n"

    _, stderr = kbsecret "raw-edit", "test-raw-edit"

    assert_match(/Missing \$EDITOR/, stderr)
  ensure
    kbsecret "rm", "test-raw-edit"
    ENV["EDITOR"] = old_editor
  end

  def test_raw_edit_no_such_record
    _, stderr = kbsecret "raw-edit", "this_record_really_should_not_exist"

    assert_match(/No such record/, stderr)
  end

  def test_raw_edit_opens_record
    # XXX: not sure how to implement this yet, given the fork/spawn issue
    skip
  end

  def test_raw_edit_accepts_session
    # XXX: not sure how to implement this yet, given the fork/spawn issue
    skip
  end
end
