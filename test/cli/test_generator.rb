# frozen_string_literal: true

require "helpers"

# tests cli command: generator
class CLIGeneratorTest < Minitest::Test
  include Aruba::Api
  include Helpers
  include Helpers::CLI

  def setup
    setup_aruba
  end

  def test_generator
    label = "test-generator"
    fmt = :base64
    length = 64
    pattern = /#{label}\n\tFormat: #{fmt}\n\tLength: #{length}/

    # add generator
    kbsecret "generator new #{label} -F #{fmt} -l #{length}"

    # retrieve generators:
    kbsecret "generators -a", interactive: false do |stdout, _|
      assert_match pattern, stdout
    end
  ensure
    # remove generator
    kbsecret "generator rm #{label}"
  end

  def test_generate
    label = "test-generator"
    fmt = :base64
    length = 16
    login_label = "test-login"
    username = "user"
    password_pattern = generator_regexp(format: fmt, length: length)
    pattern = /#{login_label}:#{username}:#{password_pattern}/

    # add generator
    kbsecret "generator new #{label} -F #{fmt} -l #{length}"

    # create login:
    kbsecret "new login -G -g #{label} #{login_label}" do |cmd|
      cmd.stdin.puts username
    end

    # retrieve login:
    kbsecret "login -x #{login_label}", interactive: false do |stdout, _|
      assert_match pattern, stdout
    end
  ensure
    # remove login:
    kbsecret "rm #{login_label}"

    # remove generator
    kbsecret "generator rm #{label}"
  end

  def test_generators_unknown_option
    label = "test-generator"
    fmt = :base64
    length = 64
    error_pattern = /Unknown option/

    # retrieve generators:
    kbsecret "generator new #{label} -F #{fmt} -l #{length} -x", interactive: false do |_, stderr|
      assert_match error_pattern, stderr
    end
  end
end
