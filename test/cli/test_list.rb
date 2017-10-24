# frozen_string_literal: true

require "helpers"

# tests cli command: list
class CLIListTest < Minitest::Test
  include Aruba::Api
  include Helpers

  def setup
    setup_aruba
  end

  def test_list
    label = "test-list"
    username = "user"
    password = "pass"
    pattern = /#{label}/

    # create login:
    run_command "kbsecret new login -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve login within the list:
    run_command "kbsecret list" do |cmd|
      cmd.wait
      assert_match pattern, cmd.output
    end
  ensure
    # remove login:
    run_command_and_stop "kbsecret rm #{label}"
  end

  def test_session
    session = "test-session"
    number = 3

    # create a new session
    run_command_and_stop "kbsecret session new -r test #{session}"

    expected = create_test_records number: number, session: session

    # retrieve records:
    run_command "kbsecret list -s #{session}" do |cmd|
      cmd.wait
      records = cmd.output.split("\n")
      assert_equal records.sort == expected.sort, true
    end
  ensure
    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session}"
  end

  def test_type
    session = "test-session"
    number = 3
    types = KBSecret::Record.record_types.map(&:to_s)

    # create a new session
    run_command_and_stop "kbsecret session new -r test #{session}"

    # create test records and an inventory
    expected = create_test_records number: number, session: session

    types.each do |type|
      filtered = expected.grep(/#{type}/)

      # retrieve records:
      run_command "kbsecret list -s #{session} -t #{type}" do |cmd|
        cmd.wait
        records = cmd.output.split("\n")
        assert_equal records.sort == filtered.sort, true
      end
    end
  ensure
    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session}"
  end

  def test_show_all
    session = "test-session"
    label = "test-show-all"
    username = "user"
    password = "pass"
    patterns = [
      /#{label}/,
      /Type: login/,
      /Last changed/,
      /Raw data.*login.*username.*#{username}.*password.*#{password}/,
    ]

    # create a new session
    run_command_and_stop "kbsecret session new -r test #{session}"

    # create login in session:
    run_command "kbsecret new login -s #{session} -x #{label}" do |cmd|
      cmd.stdin.puts "#{username}:#{password}"
      cmd.stdin.close
      cmd.wait
    end

    # retrieve list from session:
    run_command "kbsecret list --show-all -s #{session}" do |cmd|
      cmd.wait
      lines = cmd.output.split("\n")
      lines.each_with_index do |line, i|
        assert_match patterns[i], line
      end
    end
  ensure
    # remove session:
    run_command_and_stop "kbsecret session rm -d #{session}"
  end
end
