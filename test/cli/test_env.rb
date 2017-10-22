# frozen_string_literal: true

require "helpers"

# tests cli command: env
class CLIEnvTest < Minitest::Test
  include Aruba::Api
  include Helpers

  def setup
    setup_aruba
  end

  def test_env
    label = "test-env"
    variable = "api-key"
    value = "00000"
    output = "export #{variable}=#{value}"

    # create environment:
    run_command "kbsecret new environment -x #{label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve environment:
    run_command "kbsecret env #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output.chomp
    end
  ensure
    # remove environment:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_env_value_only
    label = "test-env-value-only"
    variable = "api-key"
    value = "00000"
    output = value

    # create environment:
    run_command "kbsecret new environment -x #{label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve environment - value only:
    run_command "kbsecret env --value-only #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output.chomp
    end
  ensure
    # remove environment:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_env_no_export
    label = "test-env-no-export"
    variable = "api-key"
    value = "00000"
    output = "#{variable}=#{value}"

    # create environment:
    run_command "kbsecret new environment -x #{label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve environment - no export:
    run_command "kbsecret env --no-export #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output.chomp
    end
  ensure
    # remove environment:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_all
    session = "test-session"
    label = "test-session-env"
    label1 = "test-session-env1"
    variable = "api-key"
    value = "00000"
    pattern = /export #{variable}=#{value}\nexport #{variable}=#{value}\n/

    # create a new session
    run_command_and_stop "kbsecret session new -r test #{session}"

    # create environment in the session:
    run_command "kbsecret new environment -s #{session} -x #{label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
      cmd.stdin.close
      cmd.wait
    end

    # create another environment in the session:
    run_command "kbsecret new environment -s #{session} -x #{label1}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve environments:
    run_command "kbsecret env -s #{session} -a" do |cmd|
      cmd.wait
      assert_match pattern, cmd.output
    end
  ensure
    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session}"
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
    run_command "kbsecret new environment -x #{default_label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
      cmd.stdin.close
      cmd.wait
    end

    # create a new session
    run_command_and_stop "kbsecret session new #{session} -r test"

    # create environment in session:
    run_command "kbsecret new environment -s #{session} -x #{session_label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve default environment:
    run_command "kbsecret env -s default #{default_label}" do |cmd|
      cmd.wait
      assert_equal default_output, cmd.output.chomp
    end

    # retrieve environment from session:
    run_command "kbsecret env -s #{session} #{session_label}" do |cmd|
      cmd.wait
      assert_equal session_output, cmd.output.chomp
    end

    # fail to retreive session environment from default session:
    run_command "kbsecret env #{session_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
    end

    # fail to retreive default environment from session:
    run_command "kbsecret env -s #{session} #{default_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
    end

    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session}"

    # fail to retreive environment from removed session:
    run_command "kbsecret env -s #{session} #{session_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_session, cmd.stderr
    end
  ensure
    # remove default environment:
    run_command_and_stop "kbsecret rm #{default_label}"

    # fail to retreive default environment:
    run_command "kbsecret env #{default_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
    end
  end

  def test_nonesuch
    label = "test-nonesuch"
    error_pattern = /No such record\(s\)/

    # fail to retrieve nonexistent environment:
    run_command "kbsecret env #{label}" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.stderr
    end
  end

  def test_no_label
    label = "test-no-label"
    variable = "api-key"
    value = "00000"
    error_pattern = /Too few arguments given/

    # create environment:
    run_command "kbsecret new environment -x #{label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
      cmd.stdin.close
      cmd.wait
    end

    # fail to retrieve environment without label:
    run_command "kbsecret env" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.output
    end
  ensure
    # remove environment:
    run_command_and_stop "kbsecret rm #{label}"
  end
end
