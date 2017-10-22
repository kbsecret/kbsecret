# frozen_string_literal: true

require "helpers"

# # tests cli command: env dump_fields
class CLIDumpFieldsTest < Minitest::Test
  include Aruba::Api
  include Helpers

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
    run_command "kbsecret new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve login:
    run_command "kbsecret dump-fields #{label}" do |cmd|
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
    output = <<~OUTPUT
      username:#{username}
      password:#{password}
    OUTPUT

    # create login:
    run_command "kbsecret new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve login - terse:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
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
    run_command "kbsecret new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve login - with separator:
    run_command "kbsecret dump-fields -i #{separator} -x #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
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
    run_command "kbsecret new login -x #{default_label}" do |cmd|
      cmd.stdin.puts "#{default_username}:#{default_password}"
      cmd.stdin.close
      cmd.wait
    end

    # create a new session
    run_command_and_stop "kbsecret session new #{session} -r test"

    # create login in session:
    run_command "kbsecret new login -s #{session} -x #{session_label}" do |cmd|
      cmd.stdin.puts "#{session_username}:#{session_password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve default login:
    run_command "kbsecret dump-fields -s default #{default_label}" do |cmd|
      cmd.wait
      assert_equal default_output, cmd.output
    end

    # retrieve login from session:
    run_command "kbsecret dump-fields -s #{session} #{session_label}" do |cmd|
      cmd.wait
      assert_equal session_output, cmd.output
    end

    # fail to retreive session login from default session:
    run_command "kbsecret dump-fields -s default #{session_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
    end

    # fail to retreive default login from session:
    run_command "kbsecret dump-fields -s #{session} #{default_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
    end

    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session}"

    # fail to retreive login from removed session:
    run_command "kbsecret dump-fields -s #{session} #{session_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_session, cmd.stderr
    end
  ensure
    # remove default login:
    run_command_and_stop "kbsecret rm #{default_label}"

    # fail to retreive default login:
    run_command "kbsecret dump-fields #{default_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
    end
  end

  def test_nonesuch
    label = "test-nonesuch"
    error_pattern = /No such record/

    # fail to retrieve nonexistent record:
    run_command "kbsecret dump-fields #{label}" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.stderr
    end
  end

  def test_no_label
    label = "test-no-label"
    username = "user"
    password = "pass"
    error_pattern = /Too few arguments given/

    # create record:
    run_command "kbsecret new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # fail to retrieve record without label:
    run_command "kbsecret dump-fields" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.output
    end
  ensure
    # remove record:
    run_command_and_stop "kbsecret rm #{label}"
  end
end
