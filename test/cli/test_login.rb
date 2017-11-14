# frozen_string_literal: true

require "helpers"

# tests cli command: login
class CLILoginTest < Minitest::Test
  include Aruba::Api
  include Helpers
  include Helpers::CLI

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
    kbsecret "new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # retrieve login:
    kbsecret "login #{label}", interactive: false do |stdout, _|
      assert_equal output, stdout
    end
  ensure
    # remove login:
    kbsecret "rm #{label}"
  end

  def test_terse
    label = "test-terse"
    username = "user"
    password = "pass"
    output = "#{label}:#{username}:#{password}"

    # create login:
    kbsecret "new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # retrieve login tersely:
    kbsecret "login -x #{label}", interactive: false do |stdout, _|
      assert_equal output, stdout.chomp
    end
  ensure
    # remove login:
    kbsecret "rm #{label}"
  end

  def test_terse_separator
    label = "test-terse-separator"
    username = "user"
    password = "pass"
    separator = "^"
    output = [label, username, password].join separator

    # create login:
    kbsecret "new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # retrieve login with separator:
    kbsecret "login -i #{separator} -x #{label}", interactive: false do |stdout, _|
      assert_equal output, stdout.chomp
    end
  ensure
    # remove login:
    kbsecret "rm #{label}"
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
    kbsecret "session new -r test #{session}"

    # fail to retrieve nonexistent logins:
    kbsecret "login -s #{session} -a", interactive: false do |_, stderr|
      assert_match error_pattern, stderr
    end

    # create login:
    kbsecret "new login -s #{session} -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # create another login:
    kbsecret "new login -s #{session} -x #{label1}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # retrieve logins:
    kbsecret "login --all -s #{session}", interactive: false do |stdout, _|
      stdout.lines.each_with_index do |line, i|
        assert_match patterns[i], line
      end
    end
  ensure
    # remove session:
    kbsecret "session rm -d #{session}"
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
    kbsecret "session new -r test #{session}"

    # create login:
    kbsecret "new login -s #{session} -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # create another login:
    kbsecret "new login -s #{session} -x #{label1}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # retrieve logins:
    kbsecret "login -s #{session} -ax", interactive: false do |stdout, _|
      stdout.lines.each_with_index do |line, i|
        assert_match patterns[i], line
      end
    end
  ensure
    # remove session:
    kbsecret "session rm -d #{session}"
  end

  def test_nonesuch
    label = "test-nonesuch"
    error_pattern = /No such record\(s\)/

    # fail to retrieve nonexistent login:
    kbsecret "login -x #{label}", interactive: false do |_, stderr|
      assert_match error_pattern, stderr
    end
  end

  def test_no_label
    label = "test-no-label"
    username = "user"
    password = "pass"
    error_pattern = /Too few arguments given/

    # create login:
    kbsecret "new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # fail to retrieve login without label:
    kbsecret "login", interactive: false do |_, stderr|
      assert_match error_pattern, stderr
    end
  ensure
    # remove login:
    kbsecret "rm #{label}"
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
    kbsecret "new login -x #{default_label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # create a new session
    kbsecret "session new #{session} -r test"

    # create login in session:
    kbsecret "new login -s #{session} -x #{session_label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # retrieve default login:
    kbsecret "login -s default -x #{default_label}", interactive: false do |stdout, _|
      assert_equal default_output, stdout.chomp
    end

    # retrieve login from session:
    kbsecret "login -s #{session} -x #{session_label}", interactive: false do |stdout, _|
      assert_equal session_output, stdout.chomp
    end

    # fail to retreive session login from default session:
    kbsecret "login -x #{session_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_record, stderr
    end

    # fail to retreive default login from session:
    kbsecret "login -x -s #{session} #{default_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_record, stderr
    end

    # remove session:
    kbsecret "session rm -d #{session}"

    # fail to retreive login from removed session:
    kbsecret "login -s #{session} #{session_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_session, stderr
    end
  ensure
    # remove default login:
    kbsecret "rm #{default_label}"
  end
end
