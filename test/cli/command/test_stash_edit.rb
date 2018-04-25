# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::StashEdit
class KBSecretCommandStashEditTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_raw_edit_help
    stash_edit_helps = [
      %w[stash-edit --help],
      %w[stash-edit -h],
      %w[help stash-edit],
    ]

    stash_edit_helps.each do |stash_edit_help|
      stdout, = kbsecret(*stash_edit_help)
      assert_match(/Usage:/, stdout)
    end
  end

  def test_stash_edit_too_few_arguments
    _, stderr = kbsecret "stash-edit"

    assert_match(/Too few arguments given/, stderr)
  end

  def test_stash_edit_fails_without_editor
    old_editor = ENV["EDITOR"]
    ENV.delete("EDITOR")

    kbsecret "new", "unstructured", "test-stash-edit", input: "foo\nbar\n"

    _, stderr = kbsecret "stash-edit", "test-stash-edit"

    assert_match(/Missing \$EDITOR/, stderr)
  ensure
    kbsecret "rm", "test-stash-edit"
    ENV["EDITOR"] = old_editor
  end

  def test_stash_edit_no_such_record
    with_env("EDITOR" => "cat") do
      _, stderr = kbsecret "stash-edit", "this_record_really_should_not_exist"

      assert_match(/No such unstructured record/, stderr)
    end
  end

  def test_stash_edit_base64
    # XXX: not sure how to implement this yet, given the fork/spawn issue
    skip
  end

  def test_stash_edit_opens_record
    # XXX: not sure how to implement this yet, given the fork/spawn issue
    skip
  end

  def test_stash_edit_accepts_session
    # XXX: not sure how to implement this yet, given the fork/spawn issue
    skip
  end
end
