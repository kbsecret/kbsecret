require_relative "test_helper"
require "aruba"

class CLITest < Minitest::Test
  include Aruba::Api
  include Helpers

  def setup
    setup_aruba
  end

  def test_environment
    label = "test-environment"
    variable = "api-key"
    value = "00000"
    output =  <<~OUTPUT
      variable:#{variable}
      value:#{value}
    OUTPUT

    # NOTE: bash -c workaround
    # create environment:
    run_command_and_stop "bash -c 'echo #{variable}:#{value} | kbsecret new environment -x #{label}'"

    # retrieve environment:
    run_command_and_stop "kbsecret dump-fields -x #{label}"
    assert_equal "#{output}", last_command_stopped.output
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

    # NOTE: bash -c workaround
    # create login:
    run_command_and_stop "bash -c 'echo #{username}:#{password} | kbsecret new login -x #{label}'"

    # retrieve login:
    run_command_and_stop "kbsecret dump-fields -x #{label}"
    assert_equal "#{output}", last_command_stopped.output
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

    # NOTE: bash -c workaround
    # create snippet:
    run_command_and_stop "bash -c 'echo #{code}:#{description} | kbsecret new snippet -x #{label}'"

    # retrieve snippet:
    run_command_and_stop "kbsecret dump-fields -x #{label}"
    assert_equal "#{output}", last_command_stopped.output
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
    run_command_and_stop "bash -c 'echo #{todo} | kbsecret new todo -x #{label}'"

    # retrieve todo:
    run_command_and_stop "kbsecret dump-fields -x #{label}"
    assert_equal "#{output}", last_command_stopped.output
  ensure
    # remove todo:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_unstructured
    label = "test-unstructured"
    text = "unstructured data"
    output =  "text:#{text}\n"

    # NOTE: bash -c workaround
    # create unstructured:
    run_command_and_stop "bash -c 'echo #{text} | kbsecret new unstructured -x #{label}'"

    # retrieve unstructured:
    run_command_and_stop "kbsecret dump-fields -x #{label}"
    assert_equal "#{output}", last_command_stopped.output
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

    # NOTE: bash -c workaround
    # create login:
    run_command_and_stop "bash -c 'kbsecret new login -x #{label} <<< #{username}:#{password}'"

    # retrieve login:
    run_command_and_stop "kbsecret login -x #{label}"
    assert_equal "#{label}:#{username}:#{password}", last_command_stopped.output.chomp

    # NOTE: bash -c workaround
    # force overwrite of login:
    run_command_and_stop "bash -c 'kbsecret new login --force -x #{label} <<< #{username2}:#{password2}'"

    # retrieve overwritten login:
    run_command_and_stop "kbsecret login -x #{label}"
    assert_equal "#{label}:#{username2}:#{password2}", last_command_stopped.output.chomp
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_separator
    label = "test-separator"
    username = "user"
    password = "pass"

    # NOTE: bash -c workaround
    # create login:
    run_command_and_stop "bash -c 'kbsecret new login -i ^ -x #{label} <<< #{username}^#{password}'"

    # retrieve login:
    run_command_and_stop "kbsecret login -x #{label}"
    assert_equal "#{label}:#{username}:#{password}", last_command_stopped.output.chomp
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_generate
    # NOTE: cannot test because we cannot add records interactively
    skip "-G requires interactive mode"

    label = "test-generate"
    username = "user"

    # NOTE: won't work
    # create login:
    run_command_and_stop "kbsecret new login -G -a #{label} #{username}"

    # retrieve login:
    run_command_and_stop "kbsecret login -x #{label}"
    assert_match(/#{label}:#{username}/, last_command_started.output.chomp)

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
