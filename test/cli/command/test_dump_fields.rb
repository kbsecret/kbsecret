# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command::DumpFields
class KBSecretCommandDumpFieldsTest < Minitest::Test
  include Helpers
  include Helpers::CLI

  def test_dump_fields_help
    dump_fields_helps = [
      %w[dump-fields --help],
      %w[dump-fields -h],
      %w[help dump-fields],
    ]

    dump_fields_helps.each do |dump_fields_help|
      stdout, = kbsecret(*dump_fields_help)
      assert_match(/Usage:/, stdout)
    end
  end

  def test_dump_fields_too_few_arguments
    _, stderr = kbsecret "dump-fields"

    assert_match(/Too few arguments given/, stderr)
  end

  def test_dump_fields_no_such_record
    _, stderr = kbsecret "pass", "this_record_really_should_not_exist"

    assert_match(/No such login record/, stderr)
  end

  def test_dump_fields_dump_record
    kbsecret "new", "login", "test-dump-fields", input: "foo\nbar\n"

    stdout, = kbsecret "dump-fields", "test-dump-fields"

    assert_match(/username: foo/, stdout)
    assert_match(/password: bar/, stdout)
  ensure
    kbsecret "rm", "test-dump-fields"
  end

  def test_dump_fields_dump_record_terse
    kbsecret "new", "login", "test-dump-fields-terse", input: "foo\nbar\n"

    stdout, = kbsecret "dump-fields", "test-dump-fields-terse", "-x"

    assert_match(/username:foo/, stdout)
    assert_match(/password:bar/, stdout)

    stdout, = kbsecret "dump-fields", "test-dump-fields-terse", "-xi", "$"

    assert_match(/username\$foo/, stdout)
    assert_match(/password\$bar/, stdout)

    with_env("IFS" => "%") do
      stdout, = kbsecret "dump-fields", "test-dump-fields-terse", "-x"

      assert_match(/username%foo/, stdout)
      assert_match(/password%bar/, stdout)
    end
  ensure
    kbsecret "rm", "test-dump-fields-terse"
  end

  def test_dump_fields_accepts_session
    session_label = "dump-fields-test-session"

    kbsecret "session", "new", session_label, "-r", session_label

    # N.B. we need to call this because the prior `session` call only updates `Config`
    # in its copy of the process.
    KBSecret::Config.load!

    kbsecret "new", "-s", session_label, "login", "test-dump-fields-session", input: "foo\nbar\n"

    stdout, = kbsecret "dump-fields", "-s", session_label, "test-dump-fields-session"

    assert_match(/username: foo/, stdout)
    assert_match(/password: bar/, stdout)
  ensure
    kbsecret "session", "rm", "-d", session_label
  end
end
