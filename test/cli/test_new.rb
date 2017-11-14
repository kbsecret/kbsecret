# frozen_string_literal: true

require "helpers"

# tests cli command: new
class CLINewTest < Minitest::Test
  include Aruba::Api
  include Helpers
  include Helpers::CLI

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
    kbsecret "new environment -x #{label}" do |cmd|
      cmd.stdin.puts "#{variable}:#{value}"
    end

    # retrieve environment:
    kbsecret "dump-fields -x #{label}", interactive: false do |stdout, _|
      assert_equal output.to_s, stdout
    end
  ensure
    # remove environment:
    kbsecret "rm #{label}"
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
    kbsecret "new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # retrieve login:
    kbsecret "dump-fields -x #{label}", interactive: false do |stdout, _|
      assert_equal output, stdout
    end
  ensure
    # remove login:
    kbsecret "rm #{label}"
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
    kbsecret "new snippet -x #{label}" do |cmd|
      cmd.stdin.puts "#{code}:#{description}"
    end

    # retrieve snippet:
    kbsecret "dump-fields -x #{label}", interactive: false do |stdout, _|
      assert_equal output, stdout
    end
  ensure
    # remove snippet:
    kbsecret "rm #{label}"
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
    kbsecret "new todo -x #{label}" do |cmd|
      cmd.stdin.puts todo
    end

    # retrieve todo:
    kbsecret "dump-fields -x #{label}", interactive: false do |stdout, _|
      assert_equal output, stdout
    end
  ensure
    # remove todo:
    kbsecret "rm #{label}"
  end

  def test_unstructured
    label = "test-unstructured"
    text = "unstructured data"
    output = "text:#{text}"

    # create unstructured:
    kbsecret "new unstructured -x #{label}" do |cmd|
      cmd.stdin.puts text
    end

    # retrieve unstructured:
    kbsecret "dump-fields -x #{label}", interactive: false do |stdout, _|
      assert_equal output, stdout.chomp
    end
  ensure
    # remove unstructured:
    kbsecret "rm #{label}"
  end

  def test_force
    label = "test-login-force"
    username = "user"
    password = "pass"
    username2 = "user2"
    password2 = "pass2"

    # create login:
    kbsecret "new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
    end

    # retrieve login:
    kbsecret "login -x #{label}", interactive: false do |stdout, _|
      assert_equal "#{label}:#{username}:#{password}", stdout.chomp
    end

    # force overwrite of login:
    kbsecret "new login --force -x #{label}" do |cmd|
      cmd.stdin.puts "#{username2}:#{password2}"
    end

    # retrieve overwritten login:
    kbsecret "login -x #{label}", interactive: false do |stdout, _|
      assert_equal "#{label}:#{username2}:#{password2}", stdout.chomp
    end
  ensure
    # remove login:
    kbsecret "rm #{label}"
  end

  def test_separator
    label = "test-separator"
    username = "user"
    password = "pass"

    # create login:
    kbsecret "new login -i ^ -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}^#{password}"
    end

    # retrieve login:
    kbsecret "login -x #{label}", interactive: false do |stdout, _|
      assert_equal "#{label}:#{username}:#{password}", stdout.chomp
    end
  ensure
    # remove login:
    kbsecret "rm #{label}"
  end

  def test_interactive
    label = "test-interactive"
    username = "user"
    password = "pass"

    # create login:
    kbsecret "new login #{label}" do |cmd|
      cmd.stdin.puts username
      cmd.stdin.puts password
    end

    # retrieve login:
    kbsecret "login -x #{label}", interactive: false do |stdout, _|
      assert_match(/#{label}:#{username}:#{password}/, stdout)
    end
  ensure
    # remove login:
    kbsecret "rm #{label}"
  end

  def test_generate
    label = "test-generate"
    username = "user"

    # create login:
    kbsecret "new login -G #{label}" do |cmd|
      cmd.stdin.puts username
    end

    # retrieve login:
    kbsecret "login -x #{label}", interactive: false do |stdout, _|
      assert_match(/#{label}:#{username}:\w+/, stdout)
    end
  ensure
    # remove login:
    kbsecret "rm #{label}"
  end
end
