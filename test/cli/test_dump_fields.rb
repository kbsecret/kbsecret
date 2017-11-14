# frozen_string_literal: true

require "helpers"

# # tests cli command: env dump_fields
class CLIDumpFieldsTest < Minitest::Test
  include Aruba::Api
  include Helpers
  include Helpers::CLI

  def setup
    setup_aruba
  end

  def test_dump_fields
    label = "test-dump-fields"
    username = "user"
    password = "pass"
    output = <<~OUTPUT
      username: #{username}
      password: #{password}
    OUTPUT

    # create login:
    kbsecret "new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # retrieve login:
    kbsecret "dump-fields #{label}", interactive: false do |stdout, _|
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
    output = <<~OUTPUT
      username:#{username}
      password:#{password}
    OUTPUT

    # create login:
    kbsecret "new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # retrieve login - terse:
    kbsecret "dump-fields -x #{label}", interactive: false do |stdout, _|
      assert_equal output, stdout
    end
  ensure
    # remove login:
    kbsecret "rm #{label}"
  end

  def test_terse_separator
    label = "test-terse_separator"
    username = "user"
    password = "pass"
    separator = "^"
    output = <<~OUTPUT
      username#{separator}#{username}
      password#{separator}#{password}
    OUTPUT

    # create login:
    kbsecret "new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # retrieve login - with separator:
    kbsecret "dump-fields -i #{separator} -x #{label}", interactive: false do |stdout, _|
      assert_equal output, stdout
    end
  ensure
    # remove login:
    kbsecret "rm #{label}"
  end

  def test_session
    session = "test-session"
    default_label = "test-default-login"
    session_label = "test-session-login"
    default_username = "default_username"
    default_password = "default_password"
    session_username = "session_username"
    session_password = "session_password"
    default_output = <<~OUTPUT
      username: #{default_username}
      password: #{default_password}
    OUTPUT
    session_output = <<~OUTPUT
      username: #{session_username}
      password: #{session_password}
    OUTPUT
    error_pattern_no_record = /No such record/
    error_pattern_no_session = /Unknown session/

    # create default login:
    kbsecret "new login -x #{default_label}" do |cmd|
      cmd.stdin.puts "#{default_username}:#{default_password}"
    end

    # create a new session
    kbsecret "session new #{session} -r test"

    # create login in session:
    kbsecret "new login -s #{session} -x #{session_label}" do |cmd|
      cmd.stdin.puts "#{session_username}:#{session_password}"
    end

    # retrieve default login:
    kbsecret "dump-fields -s default #{default_label}", interactive: false do |stdout, _|
      assert_equal default_output, stdout
    end

    # retrieve login from session:
    kbsecret "dump-fields -s #{session} #{session_label}", interactive: false do |stdout, _|
      assert_equal session_output, stdout
    end

    # fail to retreive session login from default session:
    kbsecret "dump-fields -s default #{session_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_record, stderr
    end

    # fail to retreive default login from session:
    kbsecret "dump-fields -s #{session} #{default_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_record, stderr
    end

    # remove session:
    kbsecret "session rm -d #{session}"

    # fail to retreive login from removed session:
    kbsecret "dump-fields -s #{session} #{session_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_session, stderr
    end
  ensure
    # remove default login:
    kbsecret "rm #{default_label}"

    # fail to retreive default login:
    kbsecret "dump-fields #{default_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_record, stderr
    end
  end

  def test_nonesuch
    label = "test-nonesuch"
    error_pattern = /No such record/

    # fail to retrieve nonexistent record:
    kbsecret "dump-fields #{label}", interactive: false do |_, stderr|
      assert_match error_pattern, stderr
    end
  end

  def test_no_label
    label = "test-no-label"
    username = "user"
    password = "pass"
    error_pattern = /Too few arguments given/

    # create record:
    kbsecret "new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # fail to retrieve record without label:
    kbsecret "dump-fields", interactive: false do |_, stderr|
      assert_match error_pattern, stderr
    end
  ensure
    # remove record:
    kbsecret "rm #{label}"
  end
end
