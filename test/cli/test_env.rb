# frozen_string_literal: true

require "helpers"

# tests cli command: env
class CLIEnvTest < Minitest::Test
  include Aruba::Api
  include Helpers
  include Helpers::CLI

  def setup
    setup_aruba
  end

  def test_env
    label = "test-env"
    variable = "api-key"
    value = "00000"
    output = "export #{variable}=#{value}"

    # create environment:
    kbsecret "new environment -x #{label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
    end

    # retrieve environment:
    kbsecret "env #{label}", interactive: false do |stdout, _|
      assert_equal output, stdout.chomp
    end
  ensure
    # remove environment:
    kbsecret "rm #{label}"
  end

  def test_env_value_only
    label = "test-env-value-only"
    variable = "api-key"
    value = "00000"
    output = value

    # create environment:
    kbsecret "new environment -x #{label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
    end

    # retrieve environment - value only:
    kbsecret "env --value-only #{label}", interactive: false do |stdout, _|
      assert_equal output, stdout.chomp
    end
  ensure
    # remove environment:
    kbsecret "rm #{label}"
  end

  def test_env_no_export
    label = "test-env-no-export"
    variable = "api-key"
    value = "00000"
    output = "#{variable}=#{value}"

    # create environment:
    kbsecret "new environment -x #{label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
    end

    # retrieve environment - no export:
    kbsecret "env --no-export #{label}", interactive: false do |stdout, _|
      assert_equal output, stdout.chomp
    end
  ensure
    # remove environment:
    kbsecret "rm #{label}"
  end

  def test_all
    session = "test-session"
    label = "test-session-env"
    label1 = "test-session-env1"
    variable = "api-key"
    value = "00000"
    pattern = /export #{variable}=#{value}\nexport #{variable}=#{value}\n/

    # create a new session
    kbsecret "session new -r test #{session}"

    # create environment in the session:
    kbsecret "new environment -s #{session} -x #{label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
    end

    # create another environment in the session:
    kbsecret "new environment -s #{session} -x #{label1}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
    end

    # retrieve environments:
    kbsecret "env -s #{session} -a", interactive: false do |stdout, _|
      assert_match pattern, stdout
    end
  ensure
    # remove session:
    kbsecret "session rm -d #{session}"
  end

  def test_session
    session = "test-session"
    default_label = "test-default-environment"
    session_label = "test-session-environment"
    variable = "api-key"
    value = "00000"
    default_output = "export #{variable}=#{value}"
    session_output = "export #{variable}=#{value}"
    error_pattern_no_record = /No such record\(s\)/
    error_pattern_no_session = /Unknown session/

    # create default environment:
    kbsecret "new environment -x #{default_label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
    end

    # create a new session
    kbsecret "session new #{session} -r test"

    # create environment in session:
    kbsecret "new environment -s #{session} -x #{session_label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
    end

    # retrieve default environment:
    kbsecret "env -s default #{default_label}", interactive: false do |stdout, _|
      assert_equal default_output, stdout.chomp
    end

    # retrieve environment from session:
    kbsecret "env -s #{session} #{session_label}", interactive: false do |stdout, _|
      assert_equal session_output, stdout.chomp
    end

    # fail to retreive session environment from default session:
    kbsecret "env #{session_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_record, stderr
    end

    # fail to retreive default environment from session:
    kbsecret "env -s #{session} #{default_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_record, stderr
    end

    # remove session:
    kbsecret "session rm -d #{session}"

    # fail to retreive environment from removed session:
    kbsecret "env -s #{session} #{session_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_session, stderr
    end
  ensure
    # remove default environment:
    kbsecret "rm #{default_label}"

    # fail to retreive default environment:
    kbsecret "env #{default_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_record, stderr
    end
  end

  def test_nonesuch
    label = "test-nonesuch"
    error_pattern = /No such record\(s\)/

    # fail to retrieve nonexistent environment:
    kbsecret "env #{label}", interactive: false do |_, stderr|
      assert_match error_pattern, stderr
    end
  end

  def test_no_label
    label = "test-no-label"
    variable = "api-key"
    value = "00000"
    error_pattern = /Too few arguments given/

    # create environment:
    kbsecret "new environment -x #{label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
    end

    # fail to retrieve environment without label:
    kbsecret "env", interactive: false do |_, stderr|
      assert_match error_pattern, stderr
    end
  ensure
    # remove environment:
    kbsecret "rm #{label}"
  end
end
