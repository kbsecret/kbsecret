# frozen_string_literal: true

require "helpers"

# tests cli command: generator
class CLIGeneratorTest < Minitest::Test
  include Aruba::Api
  include Helpers

  def setup
    setup_aruba
  end

  def test_generator
    label = "test-generator"
    format = :base64
    length = 64
    pattern = /#{label}\n\tFormat: #{format}\n\tLength: #{length}/

    # add generator
    run_command_and_stop "kbsecret generator new #{label} -F #{format} -l #{length}"

    # retrieve generators:
    run_command "kbsecret generators -a" do |cmd|
      cmd.wait
      assert_match pattern, cmd.output
    end
  ensure
    # remove generator
    run_command_and_stop "kbsecret generator rm #{label}"
  end

  def test_generate
    label = "test-generator"
    format = :base64
    length = 16
    # pattern = /#{label}\n\tFormat: #{format}\n\tLength: length.to_s/
    login_label = "test-login"
    username = "user"
    password_pattern = generator_regexp(format: format, length: length)
    pattern = /#{login_label}:#{username}:#{password_pattern}/

    # add generator
    run_command_and_stop "kbsecret generator new #{label} -F #{format} -l #{length}"

    # create login:
    run_command "kbsecret new login -G -g #{label} #{login_label}" do |cmd|
      cmd.stdin.puts username
      cmd.stdin.close
      cmd.wait
    end

    # retrieve login:
    run_command "kbsecret login -x #{login_label}" do |cmd|
      cmd.wait
      assert_match pattern, cmd.output.chomp
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{login_label}"

    # remove generator
    run_command_and_stop "kbsecret generator rm #{label}"
  end

  def test_generators_unknown_option
    label = "test-generator"
    format = :base64
    length = 64
    error_pattern = /Unknown option/

    # retrieve generators:
    run_command "kbsecret generator new #{label} -F #{format} -l #{length} -x" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.stderr
    end
  end
end
