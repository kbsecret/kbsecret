# frozen_string_literal: true

require "helpers"

# tests cli command: login
class CLILoginTest < Minitest::Test
  include Aruba::Api
  include Helpers

  def setup
    setup_aruba
  end

  def test_login
    label = "test-login"
    username = "user"
    password = "pass"
    output = <<~OUTPUT
      Label: #{label}
      \tUsername: #{username}
      \tPassword: #{password}
    OUTPUT

    # create login:
    run_command "kbsecret new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve login:
    run_command "kbsecret login #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_terse
    label = "test-terse"
    username = "user"
    password = "pass"
    output = "#{label}:#{username}:#{password}"

    # create login:
    run_command "kbsecret new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve login tersely:
    run_command "kbsecret login -x #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output.chomp
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_terse_separator
    label = "test-terse-separator"
    username = "user"
    password = "pass"
    separator = "^"
    output = [label, username, password].join separator

    # create login:
    run_command "kbsecret new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve login with separator:
    run_command "kbsecret login -i #{separator} -x #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output.chomp
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_all
    session = "test-session"
    label = "test-session-login"
    label1 = "test-session-login1"
    username = "user"
    password = "pass"
    # NOTE: can't be sure of the order in which the logins will be retreived
    patterns = [
      /(#{label}|#{label1})/,
      /#{username}/,
      /#{password}/,
      /(#{label1}|#{label})/,
      /#{username}/,
      /#{password}/,
    ]
    error_pattern = /No such record\(s\)/

    # create a new session
    run_command "kbsecret session new -r test #{session}", &:wait

    # fail to retrieve nonexistent logins:
    run_command "kbsecret login -s #{session} -a" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.stderr
    end

    # create login:
    run_command "kbsecret new login -s #{session} -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # create another login:
    run_command "kbsecret new login -s #{session} -x #{label1}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve logins:
    run_command "kbsecret login --all -s #{session}" do |cmd|
      cmd.wait
      cmd.output.lines.each_with_index do |line, i|
        assert_match patterns[i], line
      end
    end
  ensure
    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session}"
  end

  def test_all_terse
    session = "test-session"
    label = "test-session-login"
    label1 = "test-session-login1"
    username = "user"
    password = "pass"
    # NOTE: can't be sure of the order in which the logins will be retreived
    patterns = [
      /(#{label}|#{label1})/,
      /#{username}/,
      /#{password}/,
      /(#{label1}|#{label})/,
      /#{username}/,
      /#{password}/,
    ]

    # create a new session
    run_command "kbsecret session new -r test #{session}", &:wait

    # create login:
    run_command "kbsecret new login -s #{session} -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # create another login:
    run_command "kbsecret new login -s #{session} -x #{label1}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve logins:
    run_command "kbsecret login -s #{session} -ax" do |cmd|
      cmd.wait
      cmd.output.lines.each_with_index do |line, i|
        assert_match patterns[i], line
      end
    end
  ensure
    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session}"
  end

  def test_nonesuch
    label = "test-nonesuch"
    error_pattern = /No such record\(s\)/

    # fail to retrieve nonexistent login:
    run_command "kbsecret login -x #{label}" do |cmd|
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
    run_command "kbsecret login" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.output
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_session
    session = "test-session"
    default_label = "test-default-login"
    session_label = "test-session-login"
    username = "user"
    password = "pass"
    default_output = "#{default_label}:#{username}:#{password}"
    session_output = "#{session_label}:#{username}:#{password}"
    error_pattern_no_record = /No such record\(s\)/
    error_pattern_no_session = /Unknown session/

    # create default login:
    run_command "kbsecret new login -x #{default_label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # create a new session
    run_command "kbsecret session new #{session} -r test", &:wait

    # create login in session:
    run_command "kbsecret new login -s #{session} -x #{session_label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve default login:
    run_command "kbsecret login -s default -x #{default_label}" do |cmd|
      cmd.wait
      assert_equal default_output, cmd.output.chomp
    end

    # retrieve login from session:
    run_command "kbsecret login -s #{session} -x #{session_label}" do |cmd|
      cmd.wait
      assert_equal session_output, cmd.output.chomp
    end

    # fail to retreive session login from default session:
    run_command "kbsecret login -x #{session_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
    end

    # fail to retreive default login from session:
    run_command "kbsecret login -x -s #{session} #{default_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
    end

    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session}"

    # fail to retreive login from removed session:
    run_command "kbsecret login -s #{session} #{session_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_session, cmd.stderr
    end
  ensure
    # remove default login:
    run_command_and_stop "kbsecret rm #{default_label}"
  end
end
