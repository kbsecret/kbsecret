# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Generators
class KBSecretCommandGeneratorsTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_generators_help
    generators_helps = [
      %w[generators --help],
      %w[generators -h],
      %w[help generators],
    ]

    generators_helps.each do |generators_help|
      stdout, = kbsecret(*generators_help)
      assert_match(/Usage:/, stdout)
    end
  end

  def test_generators_output
    stdout, = kbsecret "generators"

    stdout.lines.each do |generator|
      generator.chomp!
      assert KBSecret::Config.generator?(generator)
    end
  end

  def test_generators_output_all
    stdout, = kbsecret "generators", "-a"

    format_lines = stdout.lines.count { |line| line =~ /Format:/ }
    length_lines = stdout.lines.count { |line| line =~ /Length:/ }

    assert_equal KBSecret::Config.generator_labels.size, format_lines
    assert_equal KBSecret::Config.generator_labels.size, length_lines
  end
end
