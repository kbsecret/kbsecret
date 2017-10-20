# frozen_string_literal: true

require_relative "test_helper"
require "aruba"

class CLINewTest < Minitest::Test
  include Aruba::Api
  include Helpers

  def setup
    setup_aruba
  end

  def test_environment
    label = "test-environment"
    variable = "api-key"
    value = "00000"
    output = <<~OUTPUT
      variable:#{variable}
      value:#{value}
    OUTPUT

    # create environment:
    run_command "kbsecret new environment -x #{label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve environment:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_equal output.to_s, cmd.output
    end
  ensure
    # remove environment:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_login
    label = "test-login"
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

    # retrieve login:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_equal output.to_s, cmd.output
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_snippet
    label = "test-snippet"
    code = "test"
    description = "an alert"
    output = <<~OUTPUT
      code:#{code}
      description:#{description}
    OUTPUT

    # create snippet:
    run_command "kbsecret new snippet -x #{label}" do |cmd|
      cmd.stdin.puts "#{code}:#{description}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve snippet:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_equal output.to_s, cmd.output
    end
  ensure
    # remove snippet:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_todo
    label = "test-todo"
    todo = "code stuff"
    output = <<~OUTPUT
      todo:#{todo}
      status:suspended
      start:
      stop:
    OUTPUT

    # NOTE: bash -c workaround
    # create todo:
    run_command "kbsecret new todo -x #{label}" do |cmd|
      cmd.stdin.puts todo
      cmd.stdin.close
      cmd.wait
    end

    # retrieve todo:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output
    end
  ensure
    # remove todo:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_unstructured
    label = "test-unstructured"
    text = "unstructured data"
    output = "text:#{text}"

    # create unstructured:
    run_command "kbsecret new unstructured -x #{label}" do |cmd|
      cmd.stdin.puts text
      cmd.stdin.close
      cmd.wait
    end

    # retrieve unstructured:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output.chomp
    end
  ensure
    # remove unstructured:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_force
    label = "test-login-force"
    username = "user"
    password = "pass"
    username2 = "user2"
    password2 = "pass2"

    # create login:
    run_command "kbsecret new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve login:
    run_command "kbsecret login -x #{label}" do |cmd|
      cmd.wait
      assert_equal "#{label}:#{username}:#{password}", cmd.output.chomp
    end

    # force overwrite of login:
    run_command "kbsecret new login --force -x #{label}" do |cmd|
      cmd.stdin.puts "#{username2}:#{password2}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve overwritten login:
    run_command "kbsecret login -x #{label}" do |cmd|
      cmd.wait
      assert_equal "#{label}:#{username2}:#{password2}", cmd.output.chomp
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_separator
    label = "test-separator"
    username = "user"
    password = "pass"

    # create login:
    run_command "kbsecret new login -i ^ -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}^#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve login:
    run_command "kbsecret login -x #{label}" do |cmd|
      cmd.wait
      assert_equal "#{label}:#{username}:#{password}", cmd.output.chomp
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_generate
    # NOTE: cannot test because we cannot add records interactively
    # The reason for this is the way `kbsecret new` tries to deduce the user's
    # input mode - it tests whether the current input is a TTY, and the current
    # test harness has no way to fake this. The solution is to drop the TTY test.
    skip "-G requires interactive mode"

    label = "test-generate"
    username = "user"

    # NOTE: won't work
    # create login:
    run_command "kbsecret new login -G #{label}" do |cmd|
      cmd.wait
      assert_match(/Username\?/, cmd.stderr)
      cmd.stdin.puts username
      cmd.stdin.close
      cmd.wait
    end

    # retrieve login:
    run_command "kbsecret login -x #{label}" do |cmd|
      cmd.wait
      assert_match(/#{label}:#{username}/, cmd.output)
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_generator
    # NOTE: cannot test because we cannot add records interactively
    skip "-g requires interactive mode"
  end

  def test_echo
    # NOTE: cannot test because we cannot add records interactively
    skip "-e requires interactive mode"
  end
end
