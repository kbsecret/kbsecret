# frozen_string_literal: true

require "helpers"

# tests cli command: todo
class CLITodoTest < Minitest::Test
  include Aruba::Api
  include Helpers

  def setup
    setup_aruba
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
    pattern_start     = /todo:#{todo}\nstatus:started\n/
    pattern_suspend   = /todo:#{todo}\nstatus:suspended\n/
    pattern_complete  = /todo:#{todo}\nstatus:complete\n/

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

    # start todo
    run_command_and_stop "kbsecret todo start #{label}"

    # retrieve started todo:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_match pattern_start, cmd.output
    end

    # suspend todo
    run_command_and_stop "kbsecret todo suspend #{label}"

    # retrieve suspended todo:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_match pattern_suspend, cmd.output
    end

    # complete todo
    run_command_and_stop "kbsecret todo complete #{label}"

    # retrieve completed todo:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_match pattern_complete, cmd.output
    end
  ensure
    # remove todo:
    run_command_and_stop "kbsecret rm #{label}"
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
    run_command "kbsecret new todo -x #{default_label}" do |cmd|
      cmd.stdin.puts default_todo
      cmd.stdin.close
      cmd.wait
    end

    # create a new session
    run_command_and_stop "kbsecret session new #{session} -r test"

    # create todo in session:
    run_command "kbsecret new todo -s #{session} -x #{session_label}" do |cmd|
      cmd.stdin.puts session_todo
      cmd.stdin.close
      cmd.wait
    end

    # retrieve default todo:
    run_command "kbsecret dump-fields -x -s default #{default_label}" do |cmd|
      cmd.wait
      assert_match default_pattern_suspend, cmd.output
    end

    # retrieve todo from session:
    run_command "kbsecret dump-fields -x -s #{session} #{session_label}" do |cmd|
      cmd.wait
      assert_match session_pattern_suspend, cmd.output
    end

    # fail to retreive session todo from default session:
    run_command "kbsecret dump-fields -x #{session_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
    end

    # fail to retreive default todo from session:
    run_command "kbsecret dump-fields -x -s #{session} #{default_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
    end

    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session}"

    # fail to retreive todo from removed session:
    run_command "kbsecret dump-fields -x -s #{session} #{session_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_session, cmd.stderr
    end
  ensure
    # remove default todo:
    run_command_and_stop "kbsecret rm #{default_label}"

    # fail to retreive default todo:
    run_command "kbsecret dump-fields -x #{default_label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
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
    run_command "kbsecret new todo -x #{label}" do |cmd|
      cmd.stdin.puts todo
      cmd.stdin.close
      cmd.wait
    end

    # create a new session
    run_command_and_stop "kbsecret session new #{session} -r test"

    # create todo in session:
    run_command "kbsecret new todo -s #{session} -x #{label}" do |cmd|
      cmd.stdin.puts todo
      cmd.stdin.close
      cmd.wait
    end

    # retrieve default todo:
    run_command "kbsecret dump-fields -x -s default #{label}" do |cmd|
      cmd.wait
      assert_match pattern_suspend, cmd.output
    end

    # retrieve todo from session:
    run_command "kbsecret dump-fields -x -s #{session} #{label}" do |cmd|
      cmd.wait
      assert_match pattern_suspend, cmd.output
    end

    # start session todo
    run_command_and_stop "kbsecret todo start -s #{session} #{label}"

    # retrieve started todo:
    run_command "kbsecret dump-fields -x -s #{session} #{label}" do |cmd|
      cmd.wait
      assert_match pattern_start, cmd.output
    end

    # confirm default todo is still suspended:
    run_command "kbsecret dump-fields -x -s default #{label}" do |cmd|
      cmd.wait
      assert_match pattern_suspend, cmd.output
    end

    # complete session todo
    run_command_and_stop "kbsecret todo complete -s #{session} #{label}"

    # retrieve completed todo:
    run_command "kbsecret dump-fields -x -s #{session} #{label}" do |cmd|
      cmd.wait
      assert_match pattern_complete, cmd.output
    end

    # confirm default todo is still suspended:
    run_command "kbsecret dump-fields -x -s default #{label}" do |cmd|
      cmd.wait
      assert_match pattern_suspend, cmd.output
    end

    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session}"

    # confirm default todo still exists:
    run_command "kbsecret dump-fields -x -s default #{label}" do |cmd|
      cmd.wait
      assert_match pattern_suspend, cmd.output
    end
  ensure
    # remove default todo:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_nonesuch
    label = "test-nonesuch"
    error_pattern = /No such record/

    # fail to retrieve nonexistent todo:
    run_command "kbsecret dump-fields -x #{label}" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.stderr
    end
  end

  def test_no_label
    label = "test-no-label"
    todo = "code stuff"
    error_pattern = /Too few arguments given/

    # create todo:
    run_command "kbsecret new todo -x #{label}" do |cmd|
      cmd.stdin.puts todo
      cmd.stdin.close
      cmd.wait
    end

    # fail to retrieve todo without label:
    run_command "kbsecret dump-fields -x" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.output
    end
  ensure
    # remove todo:
    run_command_and_stop "kbsecret rm #{label}"
  end
end
