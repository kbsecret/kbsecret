# frozen_string_literal: true

require "minitest/autorun"
require "kbsecret"

require_relative "helpers"

# Tests for KBSecret::Record and related classes/modules
class KBSecretRecordsTest < Minitest::Test
  include Helpers

  def test_record_types
    # record_types and record_classes are both arrays, and both are non-empty
    assert_instance_of Array, KBSecret::Record.record_types
    refute_empty KBSecret::Record.record_types
    assert_instance_of Array, KBSecret::Record.record_classes
    refute_empty KBSecret::Record.record_classes

    # the number of record types is the same as the number of record classes
    assert_equal KBSecret::Record.record_types.size,
                 KBSecret::Record.record_classes.size

    # all record types are symbols, correspond to a class in the list
    # of record classes, and satisfy type?
    KBSecret::Record.record_types.each do |type|
      assert_instance_of Symbol, type
      assert_includes KBSecret::Record.record_classes,
                      KBSecret::Record.class_for(type)
      assert KBSecret::Record.type?(type)
    end

    # all record classes are classes, have a type in record_types,
    # and are subclasses of Record::Abstract
    KBSecret::Record.record_classes.each do |klass|
      assert_instance_of Class, klass
      assert_includes KBSecret::Record.record_types,
                      klass.type
      assert_equal KBSecret::Record::Abstract, klass.superclass
    end
  end

  def test_record_addition_and_deletion
    temp_session do |sess|
      # creating a record in an empty session should succeed
      sess.add_record(:login, :foo, "bar", "baz")

      # record creation should throw an error if the type doesn't exist
      assert_raises KBSecret::RecordTypeUnknownError do
        sess.add_record(:this_does_not_exist, :foo, "bar")
      end

      # record creation should throw an error if the number of arguments is wrong
      assert_raises KBSecret::RecordCreationArityError do
        sess.add_record(:login, :foo, "bar") # missing an argument
      end

      assert_raises KBSecret::RecordCreationArityError do
        sess.add_record(:login, :foo, "bar", "baz", "quux") # too many arguments
      end

      # there is now 1 record in the session total, 1 of the :login type,
      # 0 of any other type, 1 session label/path, and that label satisfies record?
      refute_empty sess.records
      refute_empty sess.records(:login)
      assert_empty sess.records(:this_does_not_exist)
      refute_empty sess.record_labels
      refute_empty sess.record_paths
      assert sess.record?(:foo)

      # deleting an existent record should succeed
      sess.delete_record(:foo)

      # the session should now be empty again
      assert_empty sess.records
      assert_empty sess.records(:login)
      assert_empty sess.records(:this_does_not_exist)
      assert_empty sess.record_labels
      assert_empty sess.record_paths
      refute sess.record?(:foo)
    end
  end

  def test_record_objects
    skip
  end
end
