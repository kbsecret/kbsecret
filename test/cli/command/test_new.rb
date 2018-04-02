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

  def test_new_terse_input
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

  def test_new_generator_input
    # test the default generator profile first
    kbsecret "new", "login", "test-new-generate1", "-G", input: "foo\n"

    login1 = KBSecret::Session[:default]["test-new-generate1"]

    # the default generator could be configured as anything, so only test if password
    # is a string
    assert_equal "foo", login1.username
    assert_instance_of String, login1.password

    # create a custom generator, and use it
    kbsecret "generator", "new", "test-generator", "-F", "hex", "-l", "16"

    # N.B. we need to call this because the prior `generator` call only updates `Config`
    # in its copy of the process.
    KBSecret::Config.load!

    kbsecret "new", "login", "test-new-generate2", "-Gg", "test-generator", input: "baz\n"

    login2 = KBSecret::Session[:default]["test-new-generate2"]

    assert_equal "baz", login2.username
    assert_match(/\h{32}/, login2.password) # 32 hex chars = 16 bytes randomness
  ensure
    kbsecret "rm", "test-new-generate1", "test-new-generate2"
    kbsecret "generator", "rm", "test-generator"
  end

  def test_new_accepts_session
    session_label = "new-test-session"

    kbsecret "session", "new", session_label, "-r", session_label

    # N.B. we need to call this because the prior `session` call only updates `Config`
    # in its copy of the process.
    KBSecret::Config.load!

    kbsecret "new", "login", "-s", session_label, "test-new-session", input: "foo\nbar\n"

    refute KBSecret::Session[:default].record?("test-new-session")
    assert KBSecret::Session[session_label].record?("test-new-session")
  ensure
    kbsecret "session", "rm", "-d", session_label
  end

  def test_new_fails_on_overwrite
    kbsecret "new", "login", "test-new-overwrite", input: "foo\nbar\n"
    _, stderr = kbsecret "new", "login", "test-new-overwrite", input: "baz\nquux\n"

    assert_match(/Refusing to overwrite a record without --force/, stderr)

    login = KBSecret::Session[:default]["test-new-overwrite"]

    assert_equal "foo", login.username
    assert_equal "bar", login.password
  ensure
    kbsecret "rm", "test-new-overwrite"
  end

  def test_new_force_overwrite
    kbsecret "new", "login", "test-new-force-overwrite", input: "foo\nbar\n"
    kbsecret "new", "login", "-f", "test-new-force-overwrite", input: "baz\nquux\n"

    login = KBSecret::Session[:default]["test-new-force-overwrite"]

    assert_equal "baz", login.username
    assert_equal "quux", login.password
  ensure
    kbsecret "rm", "test-new-force-overwrite"
  end
end
