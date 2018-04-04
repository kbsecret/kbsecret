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

  def test_session_new_single_user
    skip
  end

  def test_session_new_multi_user
    skip
  end

  def test_session_new_team
    skip
  end

  def test_session_rm
    skip
  end

  def test_session_rm_and_unlink
    skip
  end
end
