# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Version
class KBSecretCommandVersionTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_version_help
    version_helps = [
      %w[version --help],
      %w[version -h],
      %w[help version],
    ]

    version_helps.each do |version_help|
      stdout, = kbsecret(*version_help)
      assert_match(/Usage:/, stdout)
    end
  end

  def test_version_output
    stdout, = kbsecret "version"

    assert_match(/kbsecret version \d\.\d\.\d/, stdout)
  end
end
