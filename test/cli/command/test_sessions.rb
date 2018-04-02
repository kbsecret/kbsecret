# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Sessions
class KBSecretCommandSessionsTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_sessions_help
    sessions_helps = [
      %w[sessions --help],
      %w[sessions -h],
      %w[help sessions],
    ]

    sessions_helps.each do |sessions_help|
      stdout, = kbsecret(*sessions_help)
      assert_match(/Usage:/, stdout)
    end
  end

  def test_sessions_outputs_list
    stdout, = kbsecret "sessions"

    stdout.lines.each do |session|
      session.chomp!
      assert KBSecret::Config.session?(session)
    end
  end

  def test_sessions_outputs_all
    # XXX: this is flaky due to something bad about the way i'm removing sessions in other
    # tests.
    skip
    stdout, = kbsecret "sessions", "-a"

    user_team_count = stdout.lines.count { |line| line =~ /(Team|Users):/ }
    secrets_root_count = stdout.lines.count { |lines| lines =~ /Secrets root:/ }

    assert_equal KBSecret::Config.session_labels.size, user_team_count.size
    assert_equal KBSecret::Config.session_labels.size, secrets_root_count.size
  end
end
