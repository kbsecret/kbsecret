# frozen_string_literal: true

require_relative "helpers"

require "fileutils"

# Tests for KBSecret::Session and related classes/modules
class KBSecretSessionsTest < Minitest::Test
  include Helpers

  def test_session_list
    # session_labels should always be an array
    assert_instance_of Array, KBSecret::Config.session_labels

    # ...and each element of that array should be a symbol that both satisfies
    # session? and refers to a configured session hash
    KBSecret::Config.session_labels.each do |label|
      assert_instance_of Symbol, label
      assert_instance_of Hash, KBSecret::Config.session(label)
      assert KBSecret::Config.session?(label)
    end
  end

  def test_default_session
    # the default session should always exist, and session? should take both a string
    # and a symbol
    assert KBSecret::Config.session?(:default)
    assert KBSecret::Config.session?("default")

    hsh = KBSecret::Config.session(:default)

    # the default session also has a configured hash, and that hash is the same whether
    # looked up by string or by symbol
    assert_instance_of Hash, hsh
    assert_equal hsh, KBSecret::Config.session("default")
  end

  def test_configure_and_deconfigure_session
    label, hsh = unique_label_and_session

    # configuring a unique session doesn't fail
    KBSecret::Config.configure_session(label, hsh)

    # the newly configured session satisfies session?, and does not change
    # when retrieved via Config.session
    assert KBSecret::Config.session?(label)
    assert_equal hsh, KBSecret::Config.session(label)

    # deconfiguring an session doesn't fail
    KBSecret::Config.deconfigure_session(label)
  end

  def test_deconfigure_nonexistent_session
    # deconfiguring a nonexistent session does nothing, and does not fail
    KBSecret::Config.deconfigure_session(:this_does_not_exist)
  end

  def test_new_empty_session
    label, hsh = unique_label_and_session
    KBSecret::Config.configure_session(label, hsh)
    sess = KBSecret::Session.new label: label

    # a brand new session has an empty array of records
    assert_instance_of Array, sess.records
    assert_empty sess.records

    # a brand new session has an empty array of records of a particular type
    assert_instance_of Array, sess.records(:login)
    assert_empty sess.records(:login)

    # a brand new session has an empty array of records of a particular type,
    # even when that type doesn't correspond to a real record type
    assert_instance_of Array, sess.records(:made_up_type)
    assert_empty sess.records(:made_up_type)

    # a brand new session has an empty array of record labels
    assert_instance_of Array, sess.record_labels
    assert_empty sess.record_labels

    # a brand new session has an empty array of record paths
    assert_instance_of Array, sess.record_paths
    assert_empty sess.record_paths

    # record? always returns false in a brand new session, since there are no labels
    # to find with any label
    refute sess.record?(:foo)
  ensure
    sess&.unlink!
    KBSecret::Config.deconfigure_session(label)
  end

  def test_bad_record_in_session
    # just to make sure the session directory exists on disk
    label, hsh = unique_label_and_session
    KBSecret::Config.configure_session(label, hsh)
    sess = KBSecret::Session.new label: label

    # create an empty JSON file, which won't parse correctly
    bad = File.join(sess.path, "foo.json")
    FileUtils.touch bad

    # attempting to load the session now should fail
    assert_raises KBSecret::Exceptions::RecordLoadError do
      sess = KBSecret::Session.new label: label
    end
  ensure
    sess&.unlink!
    KBSecret::Config.deconfigure_session(label)
  end

  def test_session_with_no_users
    label = SecureRandom.hex(10).to_sym
    hsh   = {
      users: [],
      root: SecureRandom.uuid,
    }

    KBSecret::Config.configure_session(label, hsh)

    # attempting to load a session with no users should fail
    assert_raises KBSecret::Exceptions::SessionLoadError do
      KBSecret::Session.new label: label
    end
  ensure
    KBSecret::Config.deconfigure_session(label)
  end

  def test_add_record_overwrite
    temp_session do |sess|
      # the session shouldn't contain any records before we add one
      assert_empty sess.records

      sess.add_record :login, "test-add-overwrite", "foo", "bar"

      # the session should contain exactly one record, and that record should be the one
      # we added (same type and label)
      assert_equal 1, sess.records.size
      assert_equal :login, sess["test-add-overwrite"].type

      # attempting to add a new record with the same label should fail
      assert_raises KBSecret::Exceptions::RecordOverwriteError do
        sess.add_record :environment, "test-add-overwrite", "baz", "quux"
      end

      # since the overwrite failed, the state of the session shouldn't have changed
      assert_equal 1, sess.records.size
      assert_equal :login, sess["test-add-overwrite"].type

      # ...but adding a new record with an explicit overwrite should succeed
      sess.add_record :environment, "test-add-overwrite", "baz", "quux", overwrite: true

      # the size of the session should still be 1 (since an overwrite occurred), and the record
      # in the session should be the new one
      assert_equal 1, sess.records.size
      assert_equal :environment, sess["test-add-overwrite"].type
    end
  end

  def test_import_record
    temp_session do |src|
      record_type  = :login
      record_label = "test_login"
      record_data  = %w[test password]
      src.add_record(record_type, record_label, *record_data)

      temp_session do |dst|
        # the target session shouldn't contain any records before we import one
        assert_empty dst.records

        dst.import_record(src[record_label])

        # the target session should now contain a record, and that record should be the
        # one we've imported
        refute_empty dst.records
        assert_includes dst.record_labels, record_label
      end
    end
  end

  def test_import_record_circular
    temp_session do |sess|
      sess.add_record :login, "test-import-circular", "foo", "bar"

      # importing a record into ourself should fail
      assert_raises KBSecret::Exceptions::SessionImportError do
        sess.import_record sess["test-import-circular"]
      end

      # ...but should not delete the record
      assert sess.record? "test-import-circular"
    end
  end

  def test_import_record_overwrite
    temp_session do |src|
      src.add_record :login, "test-import-overwrite", "foo", "bar"

      temp_session do |dst|
        dst.add_record :environment, "test-import-overwrite", "baz", "quux"

        # attempting to import a record with a taken label should fail
        assert_raises KBSecret::Exceptions::RecordOverwriteError do
          dst.import_record src["test-import-overwrite"]
        end

        # since the import failed, the destination session's record should be unharmed
        rec = dst["test-import-overwrite"]
        assert_equal :environment, rec.type
        assert_equal "baz", rec.variable
        assert_equal "quux", rec.value
        assert_equal dst, rec.session

        # ...but attempting to import with an overwrite should succeed
        dst.import_record src["test-import-overwrite"], overwrite: true
        rec = dst["test-import-overwrite"]

        assert_equal :login, rec.type
        assert_equal "foo", rec.username
        assert_equal "bar", rec.password
        assert_equal dst, rec.session
      end
    end
  end

  def test_equality
    temp_session do |sess1|
      # a session should be equal to itself
      assert_equal sess1, sess1

      # a session should not be equal to an object of a different class
      obj = Object.new
      refute_equal sess1, obj

      temp_session do |sess2|
        # a session should not be equal to a session with a different root
        refute_equal sess1, sess2
      end
    end
  end

  def test_equality_different_labels
    temp_session do |sess1|
      label = "different-label-equality"
      hsh = KBSecret::Config.session sess1.label

      KBSecret::Config.configure_session label, hsh
      sess2 = KBSecret::Session.new label: label

      # sessions with the same root should be equal, even if they have different labels
      assert_equal sess1, sess2

      sess2&.unlink!
      KBSecret::Config.deconfigure_session label
    end
  end
end
