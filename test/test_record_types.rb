# frozen_string_literal: true

require "minitest/autorun"
require "kbsecret"

require_relative "helpers"

# Tests for KBSecret::Record::* and related classes/modules
class KBSecretRecordTypesTest < Minitest::Test
  include Helpers

  def test_type_discovery
    # Record.type? should return true or false based on whether the type exists
    assert KBSecret::Record.type?(:login)
    refute KBSecret::Record.type?(:dfjbgdkgdf)

    # finding the class for a valid type should work
    klass = KBSecret::Record.class_for :login

    assert_instance_of Class, klass
    assert_equal KBSecret::Record::Login, klass

    # attempting to find the class for an invalid type should error
    assert_raises KBSecret::RecordTypeUnknownError do
      KBSecret::Record.class_for :kdgndfdfg
    end
  end

  def test_login_record
    temp_session do |sess|
      sess.add_record(:login, :foo, "bar", "baz")
      record = sess[:foo]

      # we put a login record in, so we expect a login record back
      assert_instance_of KBSecret::Record::Login, record

      # the data fields should be present in data_fields
      # and have the correct sensitivities
      assert_equal [:username, :password], record.data_fields
      refute record.sensitive?(:username)
      assert record.sensitive?(:password)

      # the data fields should be correctly mapped to methods
      assert_equal "bar", record.username
      assert_equal "baz", record.password

      # changing the fields should work
      record.username = "newusername"
      record.password = "hunter2"

      assert_equal "newusername", record.username
      assert_equal "hunter2", record.password
    end
  end

  def test_environment_record
    temp_session do |sess|
      sess.add_record(:environment, "top-secret-key", "FOO_API", "0xDEADBEEF")
      record = sess["top-secret-key"]

      # we put an environment record in, so we expect an environment record back
      assert_instance_of KBSecret::Record::Environment, record

      # the data fields should be present in data_fields
      # and have the correct sensitivities
      assert_equal [:variable, :value], record.data_fields
      refute record.sensitive?(:variable)
      assert record.sensitive?(:value)

      # the data fields should be correctly mapped to methods
      assert_equal "FOO_API", record.variable
      assert_equal "0xDEADBEEF", record.value

      # the export and assignment methods should work
      assert_equal "export FOO_API=0xDEADBEEF", record.to_export
      assert_equal "FOO_API=0xDEADBEEF", record.to_assignment

      # changing the fields should work
      record.variable = "BAR_API"
      record.value = "0xFEEDFACE"

      assert_equal "BAR_API", record.variable
      assert_equal "0xFEEDFACE", record.value

      assert_equal "export BAR_API=0xFEEDFACE", record.to_export
      assert_equal "BAR_API=0xFEEDFACE", record.to_assignment
    end
  end

  def test_snippet_record
    temp_session do |sess|
      sess.add_record(:snippet, :foo, "echo bar", "echoes bar")
      record = sess[:foo]

      # we put a snippet record in, so we expect a snippet record back
      assert_instance_of KBSecret::Record::Snippet, record

      # the data fields should be present in data_fields
      # and have the correct sensitivities
      assert_equal [:code, :description], record.data_fields
      refute record.sensitive?(:code)
      refute record.sensitive?(:description)

      # the data fields should be correctly mapped to methods
      assert_equal "echo bar", record.code
      assert_equal "echoes bar", record.description

      # changing the fields should work
      record.code = "echo baz"
      record.description = "echoes baz"

      assert_equal "echo baz", record.code
      assert_equal "echoes baz", record.description
    end
  end

  def test_todo_record
    temp_session do |sess|
      sess.add_record(:todo, "task-1", "clean the kitchen")
      record = sess["task-1"]

      # we put a todo record in, so we expect a todo record back
      assert_instance_of KBSecret::Record::Todo, record

      # the data fields should be present in data_fields
      # and have the correct sensitivities
      assert_equal [:todo, :status, :start, :stop], record.data_fields
      refute record.sensitive?(:todo)
      refute record.sensitive?(:status)
      refute record.sensitive?(:start)
      refute record.sensitive?(:stop)

      # the data fields should be correctly mapped to methods
      assert_equal "clean the kitchen", record.todo
      assert_equal "suspended", record.status

      # the start and stop times should be nil, since we haven't started or stopped
      # the todo yet
      assert_nil record.start
      assert_nil record.stop

      # status predicates should work
      refute record.started?
      assert record.suspended?
      refute record.completed?

      # mark the todo as started
      record.start!

      assert record.started?
      refute record.suspended?
      refute record.completed?

      # now that the todo is started, start should be a (stringified) timestamp
      assert_instance_of String, record.start

      # mark the todo as complete
      record.complete!

      refute record.started?
      refute record.suspended?
      assert record.completed?

      # now that the todo is complete, stop should be a (stringified) timestamp
      assert_instance_of String, record.stop
      # ...and the start timestamp should still be intact
      assert_instance_of String, record.start

      # changing the fields should work
      record.todo = "empty the dishwasher"

      assert_equal "empty the dishwasher", record.todo
    end
  end

  def test_unstructured_record
    temp_session do |sess|
      sess.add_record(:unstructured, :junk, "this is some random text")
      record = sess[:junk]

      # we put an unstructured record in, so we expect an unstructured record back
      assert_instance_of KBSecret::Record::Unstructured, record

      # the data fields should be present in data_fields
      # and have the correct sensitivities
      assert_equal [:text], record.data_fields
      refute record.sensitive?(:text)

      # the data fields should be correctly mapped to methods
      assert_equal "this is some random text", record.text

      # changing the fields should work
      record.text = "this is some other text"

      assert_equal "this is some other text", record.text
    end
  end
end
