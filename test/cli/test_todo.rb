# frozen_string_literal: true

require "helpers"

# tests cli command: todo
class CLITodoTest < Minitest::Test
  include Aruba::Api
  include Helpers
  include Helpers::CLI

  def setup
    setup_aruba
  end

  def test_todo
    label  = "test-todo"
    todo   = "code stuff"
    output = <<~OUTPUT
      todo:#{todo}
      status:suspended
      start:
      stop:
    OUTPUT
    pattern_start     = /todo:#{todo}\nstatus:started\n/
    pattern_suspend   = /todo:#{todo}\nstatus:suspended\n/
    pattern_complete  = /todo:#{todo}\nstatus:complete\n/

    # create todo:
    kbsecret "new todo -x #{label}" do |cmd|
      cmd.stdin.puts todo
    end

    # retrieve todo:
    kbsecret "dump-fields -x #{label}", interactive: false do |stdout, _|
      assert_equal output, stdout
    end

    # start todo
    kbsecret "todo start #{label}"

    # retrieve started todo:
    kbsecret "dump-fields -x #{label}", interactive: false do |stdout, _|
      assert_match pattern_start, stdout
    end

    # suspend todo
    kbsecret "todo suspend #{label}"

    # retrieve suspended todo:
    kbsecret "dump-fields -x #{label}", interactive: false do |stdout, _|
      assert_match pattern_suspend, stdout
    end

    # complete todo
    kbsecret "todo complete #{label}"

    # retrieve completed todo:
    kbsecret "dump-fields -x #{label}", interactive: false do |stdout, _|
      assert_match pattern_complete, stdout
    end
  ensure
    # remove todo:
    kbsecret "rm #{label}"
  end

  def test_session
    session = "test-session"
    default_label = "test-default-todo"
    session_label = "test-session-todo"
    default_todo = "code stuff"
    session_todo = "read stuff"
    default_pattern_suspend   = /todo:#{default_todo}\nstatus:suspended\n/
    session_pattern_suspend   = /todo:#{session_todo}\nstatus:suspended\n/
    error_pattern_no_record = /No such record/
    error_pattern_no_session = /Unknown session/

    # create default todo:
    kbsecret "new todo -x #{default_label}" do |cmd|
      cmd.stdin.puts default_todo
    end

    # create a new session
    kbsecret "session new #{session} -r test"

    # create todo in session:
    kbsecret "new todo -s #{session} -x #{session_label}" do |cmd|
      cmd.stdin.puts session_todo
    end

    # retrieve default todo:
    kbsecret "dump-fields -x -s default #{default_label}", interactive: false do |stdout, _|
      assert_match default_pattern_suspend, stdout
    end

    # retrieve todo from session:
    kbsecret "dump-fields -x -s #{session} #{session_label}", interactive: false do |stdout, _|
      assert_match session_pattern_suspend, stdout
    end

    # fail to retreive session todo from default session:
    kbsecret "dump-fields -x #{session_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_record, stderr
    end

    # fail to retreive default todo from session:
    kbsecret "dump-fields -x -s #{session} #{default_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_record, stderr
    end

    # remove session:
    kbsecret "session rm -d #{session}"

    # fail to retreive todo from removed session:
    kbsecret "dump-fields -x -s #{session} #{session_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_session, stderr
    end
  ensure
    # remove default todo:
    kbsecret "rm #{default_label}"

    # fail to retreive default todo:
    kbsecret "dump-fields -x #{default_label}", interactive: false do |_, stderr|
      assert_match error_pattern_no_record, stderr
    end
  end

  def test_session_overlap
    session = "test-session"
    label = "test-todo"
    todo = "code stuff"
    pattern_start     = /todo:#{todo}\nstatus:started\n/
    pattern_suspend   = /todo:#{todo}\nstatus:suspended\n/
    pattern_complete  = /todo:#{todo}\nstatus:complete\n/

    # create default todo:
    kbsecret "new todo -x #{label}" do |cmd|
      cmd.stdin.puts todo
    end

    # create a new session
    kbsecret "session new #{session} -r test"

    # create todo in session:
    kbsecret "new todo -s #{session} -x #{label}" do |cmd|
      cmd.stdin.puts todo
    end

    # retrieve default todo:
    kbsecret "dump-fields -x -s default #{label}", interactive: false do |stdout, _|
      assert_match pattern_suspend, stdout
    end

    # retrieve todo from session:
    kbsecret "dump-fields -x -s #{session} #{label}", interactive: false do |stdout, _|
      assert_match pattern_suspend, stdout
    end

    # start session todo
    kbsecret "todo start -s #{session} #{label}"

    # retrieve started todo:
    kbsecret "dump-fields -x -s #{session} #{label}", interactive: false do |stdout, _|
      assert_match pattern_start, stdout
    end

    # confirm default todo is still suspended:
    kbsecret "dump-fields -x -s default #{label}", interactive: false do |stdout, _|
      assert_match pattern_suspend, stdout
    end

    # complete session todo
    kbsecret "todo complete -s #{session} #{label}"

    # retrieve completed todo:
    kbsecret "dump-fields -x -s #{session} #{label}", interactive: false do |stdout, _|
      assert_match pattern_complete, stdout
    end

    # confirm default todo is still suspended:
    kbsecret "dump-fields -x -s default #{label}", interactive: false do |stdout, _|
      assert_match pattern_suspend, stdout
    end

    # remove session:
    kbsecret "session rm -d #{session}"

    # confirm default todo still exists:
    kbsecret "dump-fields -x -s default #{label}", interactive: false do |stdout, _|
      assert_match pattern_suspend, stdout
    end
  ensure
    # remove default todo:
    kbsecret "rm #{label}"
  end

  def test_nonesuch
    label = "test-nonesuch"
    error_pattern = /No such record/

    # fail to retrieve nonexistent todo:
    kbsecret "dump-fields -x #{label}", interactive: false do |_, stderr|
      assert_match error_pattern, stderr
    end
  end

  def test_no_label
    label = "test-no-label"
    todo = "code stuff"
    error_pattern = /Too few arguments given/

    # create todo:
    kbsecret "new todo -x #{label}" do |cmd|
      cmd.stdin.puts todo
    end

    # fail to retrieve todo without label:
    kbsecret "dump-fields -x", interactive: false do |_, stderr|
      assert_match error_pattern, stderr
    end
  ensure
    # remove todo:
    kbsecret "rm #{label}"
  end
end
