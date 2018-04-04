# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Generator
class KBSecretCommandGeneratorTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_generator_help
    generator_helps = [
      %w[generator --help],
      %w[generator -h],
      %w[help generator],
    ]

    generator_helps.each do |generator_help|
      stdout, = kbsecret(*generator_help)
      assert_match "Usage:", stdout
    end
  end

  def test_generator_too_few_arguments
    _, stderr = kbsecret "generator"

    assert_match "Too few arguments given", stderr

    _, stderr = kbsecret "generator", "new"

    assert_match "Too few arguments given", stderr
  end

  def test_generator_unknown_subcommand
    _, stderr = kbsecret "generator", "made-up-subcommand", "foo"

    assert_match "Unknown subcommand", stderr
  end

  def test_generator_new
    kbsecret "generator", "new", "test-generator-new"

    assert KBSecret::Config.generator?("test-generator-new")

    kbsecret "generator", "new", "-F", "base64", "-l", "32", "test-generator-new-flags"

    assert KBSecret::Config.generator?("test-generator-new-flags")
  ensure
    kbsecret "generator", "rm", "test-generator-new"
    kbsecret "generator", "rm", "test-generator-new-flags"
  end

  def test_generator_rm
    kbsecret "generator", "new", "test-generator-rm"

    assert KBSecret::Config.generator?("test-generator-rm")

    kbsecret "generator", "rm", "test-generator-rm"

    refute KBSecret::Config.generator?("test-generator-rm")
  end

  def test_generator_rm_fails_on_unknown_generator
    _, stderr = kbsecret "generator", "rm", "this-should-not-exist"

    assert_match "Unknown generator profile", stderr
  end

  def test_generator_fails_on_overwrite
    kbsecret "generator", "new", "test-generator-overwrite-fail"
    _, stderr = kbsecret "generator", "new", "test-generator-overwrite-fail"

    assert_match "Refusing to overwrite an existing generator without --force", stderr
  ensure
    kbsecret "rm", "test-generator-overwrite-fail"
  end

  def test_generator_force_overwrite
    kbsecret "generator", "new", "test-generator-overwrite", "-F", "base64", "-l", "32"

    gen = KBSecret::Generator.new "test-generator-overwrite"

    assert_equal :base64, gen.format
    assert_equal 32, gen.length

    kbsecret "generator", "new", "-f", "test-generator-overwrite", "-F", "hex", "-l", "16"

    gen = KBSecret::Generator.new "test-generator-overwrite"

    assert_equal :hex, gen.format
    assert_equal 16, gen.length
  ensure
    kbsecret "generator", "rm", "test-generator-overwrite"
  end
end
