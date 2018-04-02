# frozen_string_literal: true

require "helpers"

# tests cli command: session
class CLISessionTest < Minitest::Test
  include Aruba::Api
  include Helpers

  def setup
    setup_aruba
  end

  def test_session
    session_1 = "session_one"
    session_2 = "session_two"
    session_1_label = "session-one-unstructured"
    session_2_label = "session-two-unstructured"
    session_1_text = "session one unstructured data"
    session_2_text = "session two unstructured data"
    session_1_output = "text:#{session_1_text}"
    session_2_output = "text:#{session_2_text}"
    error_pattern = /No such record/

    # create a session:
    run_command_and_stop "kbsecret session new -r test #{session_1}"

    # create record in session:
    run_command "kbsecret new unstructured -s #{session_1} -x #{session_1_label}" do |cmd|
      cmd.stdin.puts session_1_text
      cmd.stdin.close
      cmd.wait
    end

    # retrieve record from session:
    run_command "kbsecret dump-fields -s #{session_1} -x #{session_1_label}" do |cmd|
      cmd.wait
      assert_equal session_1_output, cmd.output.chomp
    end

    # create another session:
    run_command_and_stop "kbsecret session new -r test #{session_2}"

    # create record in second session:
    run_command "kbsecret new unstructured -s #{session_2} -x #{session_2_label}" do |cmd|
      cmd.stdin.puts session_2_text
      cmd.stdin.close
      cmd.wait
    end

    # retrieve record from second session:
    run_command "kbsecret dump-fields -s #{session_2} -x #{session_2_label}" do |cmd|
      cmd.wait
      assert_equal session_2_output, cmd.output.chomp
    end

    # FIXME: this test actually fails.
    # my expectation had been that separate sessions held records separately
    # even if they were in the same root. this test demonstrates that this isn't the case.
    # if this is your intent, i'd suggest making this clearer in the docs, and i can revise this test.
    # if that wasn't your intent, then this test should pass.
    # fail to retrieve record from wrong session:
    run_command "kbsecret dump-fields -s #{session_1} -x #{session_2_label}" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.output
    end

    # remove record from session:
    run_command_and_stop "kbsecret rm -s #{session_1} #{session_1_label}"

    # fail to retrieve record from session:
    run_command "kbsecret dump-fields -s #{session_1} -x #{session_1_label}" do |cmd|
      cmd.wait
      assert_match error_pattern, cmd.stderr
    end

    # retrieve unaffected record from second session:
    run_command "kbsecret dump-fields -s #{session_2} -x #{session_2_label}" do |cmd|
      cmd.wait
      assert_equal session_2_output, cmd.output.chomp
    end

  ensure
    # remove first session:
    run_command_and_stop "kbsecret session rm -d #{session_1} --no-warn"

    # remove second session:
    run_command_and_stop "kbsecret session rm -d #{session_2} --no-warn"
  end

  def test_remove
    session = "test_session"
    label = "session-record"
    text = "session unstructured data"
    output = "text:#{text}"
    error_pattern_no_record = /No such record/
    error_pattern_no_session = /Unknown session/

    # create a session:
    run_command_and_stop "kbsecret session new -r test #{session}"

    # create record in session:
    run_command "kbsecret new unstructured -s #{session} -x #{label}" do |cmd|
      cmd.stdin.puts text
      cmd.stdin.close
      cmd.wait
    end

    # retrieve record from session:
    run_command "kbsecret dump-fields -s #{session} -x #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output.chomp
    end

    # remove session non-destructively:
    run_command_and_stop "kbsecret session rm #{session}"

    # fail to retrieve record from removed session:
    run_command "kbsecret dump-fields -s #{session} -x #{label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_session, cmd.stderr
    end

    # re-create session:
    run_command_and_stop "kbsecret session new -r test #{session}"

    # retrieve record from restored session:
    run_command "kbsecret dump-fields -s #{session} -x #{label}" do |cmd|
      cmd.wait
      assert_equal output, cmd.output.chomp
    end

    # remove session destructively:
    run_command_and_stop "kbsecret session rm -d #{session}"

    # fail to retrieve record from removed session:
    run_command "kbsecret dump-fields -s #{session} -x #{label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_session, cmd.stderr
    end

    # re-create session again:
    run_command_and_stop "kbsecret session new -r test #{session}"

    # fail to retrieve destroyed record from re-created session:
    run_command "kbsecret dump-fields -s #{session} -x #{label}" do |cmd|
      cmd.wait
      assert_match error_pattern_no_record, cmd.stderr
    end

  ensure
    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session} --no-warn"
  end
end
