# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::Todo
class KBSecretCommandTodoTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_todo_help
    todo_helps = [
      %w[todo --help],
      %w[todo -h],
      %w[help todo],
    ]

    todo_helps.each do |todo_help|
      stdout, = kbsecret(*todo_help)
      assert_match "Usage:", stdout
    end
  end

  def test_todo_too_few_arguments
    _, stderr = kbsecret "todo"

    assert_match "Too few arguments given", stderr

    _, stderr = kbsecret "todo", "start"

    assert_match "Too few arguments given", stderr
  end

  def test_todo_no_such_record
    _, stderr = kbsecret "todo", "start", "this-does-not-exist"

    assert_match "No such todo record", stderr

    kbsecret "new", "login", "test-todo-filters-type", input: "foo\nbar\n"

    _, stderr = kbsecret "todo", "start", "test-todo-filters-type"

    assert_match "No such todo record", stderr
  ensure
    kbsecret "rm", "test-todo-filters-type"
  end

  def test_todo_unknown_subcommand
    kbsecret "new", "todo", "test-todo-unknown-subcommand", input: "laundry\n"

    _, stderr = kbsecret "todo", "made-up-subcommand", "test-todo-unknown-subcommand"

    assert_match "Unknown subcommand:", stderr
  ensure
    kbsecret "rm", "test-todo-unknown-subcommand"
  end

  def test_todo_subcommands
    kbsecret "new", "todo", "test-todo-subcommands", input: "laundry\n"

    stdout, = kbsecret "todo", "start", "test-todo-subcommands"

    assert_match "marked as started", stdout

    stdout, = kbsecret "todo", "suspend", "test-todo-subcommands"

    assert_match "marked as suspended", stdout

    stdout, = kbsecret "todo", "complete", "test-todo-subcommands"

    assert_match "marked as completed", stdout
  ensure
    kbsecret "rm", "test-todo-subcommands"
  end

  def test_todo_accepts_session
    kbsecret "session", "new", "todo-test-session", "-r", "todo-test-session"
    kbsecret "new", "-s", "todo-test-session", "todo", "test-todo-session"

    stdout, = kbsecret "todo", "-s", "todo-test-session", "start", "test-todo-session"

    assert_match "marked as started", stdout
  ensure
    kbsecret "session", "rm", "-d", "todo-test-session"
  end
end
