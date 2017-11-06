# frozen_string_literal: true

require "helpers"

# tests cli command: rm
class CLIRmTest < Minitest::Test
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
    error_pattern = /No such record/

    # create environment:
    run_command "kbsecret new environment -x #{label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve environment:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output
    end

    # remove environment:
    run_command_and_stop "kbsecret rm #{label}"

    # fail to retrieve removed environment:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.output
    end
  end

  def test_login
    label = "test-login"
    username = "user"
    password = "pass"
    output = <<~OUTPUT
      username:#{username}
      password:#{password}
    OUTPUT
    error_pattern = /No such record/

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

    # remove login:
    run_command_and_stop "kbsecret rm #{label}"

    # fail to retrieve removed login:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.output
    end
  end

  def test_snippet
    label = "test-snippet"
    code = "test"
    description = "an alert"
    output = <<~OUTPUT
      code:#{code}
      description:#{description}
    OUTPUT
    error_pattern = /No such record/

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

    # remove snippet:
    run_command_and_stop "kbsecret rm #{label}"

    # fail to retrieve removed snippet:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.output
    end
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
    error_pattern = /No such record/

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

    # remove todo:
    run_command_and_stop "kbsecret rm #{label}"

    # fail to retrieve removed todo:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.output
    end
  end

  def test_unstructured
    label = "test-unstructured"
    text = "unstructured data"
    output = "text:#{text}"
    error_pattern = /No such record/

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

    # remove unstructured:
    run_command_and_stop "kbsecret rm #{label}"

    # fail to retrieve removed unstructured:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.output
    end
  end

  def test_session
    session = "test-session"
    default_label = "test-default-unstructured"
    session_label = "test-session-unstructured"
    default_text = "default unstructured data"
    session_text = "session unstructured data"
    default_output = "text:#{default_text}"
    session_output = "text:#{session_text}"
    error_pattern = /No such record/

    # create default unstructured:
    run_command "kbsecret new unstructured -x #{default_label}" do |cmd|
      cmd.stdin.puts default_text
      cmd.stdin.close
      cmd.wait
    end

    # create a new session
    run_command_and_stop "kbsecret session new -r test #{session}"

    # create unstructured in session:
    run_command "kbsecret new unstructured -s #{session} -x #{session_label}" do |cmd|
      cmd.stdin.puts session_text
      cmd.stdin.close
      cmd.wait
    end

    # retrieve default unstructured:
    run_command "kbsecret dump-fields -s default -x #{default_label}" do |cmd|
      cmd.wait
      assert_equal default_output, cmd.output.chomp
    end

    # retrieve unstructured from session:
    run_command "kbsecret dump-fields -s #{session} -x #{session_label}" do |cmd|
      cmd.wait
      assert_equal session_output, cmd.output.chomp
    end

    # remove unstructured from session:
    run_command_and_stop "kbsecret rm -s #{session} #{session_label}"

    # fail to retreive unstructured from session:
    run_command "kbsecret dump-fields -s #{session} -x #{session_label}" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.stderr
    end

    # retrieve unaffected default unstructured:
    run_command "kbsecret dump-fields -s default -x #{default_label}" do |cmd|
      cmd.wait
      assert_equal default_output, cmd.output.chomp
    end

  ensure
    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session} --no-warn"

    # remove default login:
    run_command_and_stop "kbsecret rm #{default_label} --no-warn"
  end

  def test_interactive
    label = "test-interactive"
    text = "unstructured data"
    output = "text:#{text}"
    error_pattern = /No such record/

    # create unstructured:
    run_command "kbsecret new unstructured -x #{label}" do |cmd|
      cmd.stdin.puts text
      cmd.stdin.close
      cmd.wait
    end

    # retrieve unstructured:
    run_command "kbsecret dump-fields -s default -x #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output.chomp
    end

    # opt to not remove unstructured interactively:
    run_command "kbsecret rm #{label} --interactive" do |cmd|
      # respond to: Delete 'test' from the default session? (Y/n)
      cmd.stdin.puts 'n'
      cmd.stdin.close
      cmd.wait
    end

    # retrieve unaffected unstructured:
    run_command "kbsecret dump-fields -s default -x #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output.chomp
    end

    # remove unstructured interactively:
    run_command "kbsecret rm #{label} --interactive" do |cmd|
      # respond to: Delete 'test' from the default session? (Y/n)
      cmd.stdin.puts 'Y'
      cmd.stdin.close
      cmd.wait
    end

    # fail to retrieve unstructured:
    run_command "kbsecret dump-fields -s default -x #{label}" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.output.chomp
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

    # fail to remove login without label:
    run_command "kbsecret rm" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.output
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end
end
