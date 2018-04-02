# frozen_string_literal: true

require "helpers"

# tests cli command: pass
class CLIPassTest < Minitest::Test
  include Aruba::Api
  include Helpers

  def setup
    setup_aruba
  end

  def test_pass
    label = "test-login"
    username = "user"
    password = "pass"
    output = password

    # create login:
    run_command "kbsecret new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve login:
    run_command "kbsecret pass #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output.chomp
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_session
    session = "test-session"
    default_label = "test-default-login"
    session_label = "test-session-login"
    default_username = "default_user"
    default_password = "default_pass"
    session_username = "session_user"
    session_password = "session_pass"
    default_output = default_password
    session_output = session_password
    error_pattern_no_record = /No such record/
    error_pattern_no_session = /Unknown session/

    # create default login:
    run_command "kbsecret new login -x #{default_label}" do |cmd|
      cmd.stdin.puts "#{default_username}:#{default_password}"
      cmd.stdin.close
      cmd.wait
    end

    # create a new session
    run_command "kbsecret session new #{session} -r test", &:wait

    # create login in session:
    run_command "kbsecret new login -s #{session} -x #{session_label}" do |cmd|
      cmd.stdin.puts "#{session_username}:#{session_password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve default login:
    run_command "kbsecret pass -s default #{default_label}" do |cmd|
      cmd.wait
      assert_equal default_output, cmd.output.chomp
    end

    # retrieve login from session:
    run_command "kbsecret pass -s #{session} #{session_label}" do |cmd|
      cmd.wait
      assert_equal session_output, cmd.output.chomp
    end

    # fail to retreive session login from default session:
    run_command "kbsecret pass #{session_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
    end

    # fail to retreive default login from session:
    run_command "kbsecret pass -s #{session} #{default_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
    end

    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session}"

    # fail to retreive login from removed session:
    run_command "kbsecret pass -s #{session} #{session_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_session, cmd.stderr
    end
  ensure
    # remove default login:
    run_command_and_stop "kbsecret rm #{default_label}"
  end

  def test_nonesuch
    label = "test-nonesuch"
    error_pattern = /No such record/

    # fail to retrieve nonexistent login:
    run_command "kbsecret pass #{label}" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.stderr
    end
  end

  def test_no_label
    label = "test-no-label"
    username = "user"
    password = "pass"
    error_pattern = /Too few arguments given/

    # create login:
    run_command "kbsecret new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # fail to retrieve login without label:
    run_command "kbsecret pass" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.output
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end
end
