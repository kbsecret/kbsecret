# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::New
class KBSecretCommandNewTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_new_login_record
    kbsecret "new", "login", "test-new-login", input: "foo\nbar\n"

    login = KBSecret::Session[:default]["test-new-login"]

    assert_equal "foo", login.username
    assert_equal "bar", login.password
  ensure
    kbsecret "rm", "test-new-login"
  end

  def test_new_environment_record
    kbsecret "new", "environment", "test-new-env", input: "key\nvalue\n"

    env = KBSecret::Session[:default]["test-new-env"]

    assert_equal "key", env.variable
    assert_equal "value", env.value
  ensure
    kbsecret "rm", "test-new-env"
  end

  def test_new_snippet_record
    kbsecret "new", "snippet", "test-new-snip", input: "echo hello world\ndescription\n"

    snip = KBSecret::Session[:default]["test-new-snip"]

    assert_equal "echo hello world", snip.code
    assert_equal "description", snip.description
  ensure
    kbsecret "rm", "test-new-snip"
  end

  def test_new_unstructured_record
    kbsecret "new", "unstructured", "test-new-unstructured", input: "some data\n"

    unstructured = KBSecret::Session[:default]["test-new-unstructured"]

    assert_equal "some data", unstructured.text
  ensure
    kbsecret "rm", "test-new-unstructured"
  end

  def test_new_todo_record
    kbsecret "new", "todo", "test-new-todo", input: "do laundry\n"

    todo = KBSecret::Session[:default]["test-new-todo"]

    assert_equal "do laundry", todo.todo
    assert_predicate todo, :suspended?
  ensure
    kbsecret "rm", "test-new-todo"
  end

  def test_terse_input
    kbsecret "new", "login", "test-new-terse1", "-x", input: "foo:bar\n"
    kbsecret "new", "login", "test-new-terse2", "-xi", "~", input: "baz~quux\n"

    login1 = KBSecret::Session[:default]["test-new-terse1"]
    login2 = KBSecret::Session[:default]["test-new-terse2"]

    assert_equal "foo", login1.username
    assert_equal "bar", login1.password
    assert_equal "baz", login2.username
    assert_equal "quux", login2.password
  ensure
    kbsecret "rm", "test-new-terse1", "test-new-terse2"
  end

  def test_generator_input
    skip
  end
end
