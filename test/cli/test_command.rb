# frozen_string_literal: true

require "helpers"

# Tests for KBSecret::CLI::Command
class KBSecretCommandTest < Minitest::Test
  include Helpers

  def test_internal_command_classes_and_names
    command_classes = KBSecret::CLI::Command.internal_command_classes
    command_names = KBSecret::CLI::Command.internal_command_names

    # command_classes and command_names are both arrays, and both are non-empty
    assert_instance_of Array, command_classes
    refute_empty command_classes
    assert_instance_of Array, command_names
    refute_empty command_names

    # the number of command classes is the same as the number of command names
    assert_equal command_classes.size, command_names.size

    # each member of command_names is a String, has a corresponding class in command_classes,
    # and satisfies internal?
    command_names.each do |cmd_name|
      assert_instance_of String, cmd_name
      assert_instance_of Class, KBSecret::CLI::Command.internal_command_for(cmd_name)
      assert KBSecret::CLI::Command.internal?(cmd_name)
    end

    # each member of command_classes is a Class, has a command_name in command_names,
    # satisfies internal? with its command_name, and is a subclass of
    # KBSecret::CLI::Command::Abstract
    command_classes.each do |klass|
      assert_instance_of Class, klass
      assert_includes command_names, klass.command_name
      assert KBSecret::CLI::Command.internal?(klass.command_name)
      assert_equal KBSecret::CLI::Command::Abstract, klass.superclass
    end
  end

  def test_external_command_paths_and_names
    command_paths = KBSecret::CLI::Command.external_command_paths
    command_names = KBSecret::CLI::Command.external_command_names

    # command_paths and command_names are both arrays, although both may be empty
    assert_instance_of Array, command_paths
    assert_instance_of Array, command_names

    # each member of command_paths exists on disk
    command_paths.each do |path|
      assert File.file?(path)
    end

    # each member of command_names satisfies external?
    command_names.each do |cmd_name|
      assert KBSecret::CLI::Command.external?(cmd_name)
    end
  end
end
