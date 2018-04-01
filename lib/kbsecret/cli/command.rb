# frozen_string_literal: true

# we have to require abstract first because ruby's module resolution is bad
require_relative "command/abstract"
Dir[File.join(__dir__, "command/*.rb")].each { |t| require_relative t }

module KBSecret
  class CLI
    # The namespace for {KBSecret}'s commands.
    module Command
      module_function

      # The fully-qualified paths of all external commands visible to {KBSecret}.
      # @return [Array<String>] the fully-qualified paths of all external commands
      def external_command_paths
        ENV["PATH"].split(File::PATH_SEPARATOR).map do |path|
          Dir[File.join(path, "kbsecret-*")]
        end.flatten.uniq.freeze
      end

      # The CLI-friendly names of all external commands
      def external_command_names
        external_command_paths.map do |c|
          File.basename(c, File.extname(c)).sub!("kbsecret-", "")
        end.freeze
      end

      # @return [Boolean] whether or not there is an external command with the given name
      def external?(command_name)
        external_command_names.include?(command_name)
      end

      # @return [Array<Class>] the class objects of all non-abstract internal commands
      def internal_command_classes
        klasses = constants.map(&Command.method(:const_get)).grep(Class)
        klasses.delete(Command::Abstract)
        klasses
      end

      # @return [Array<String>] the CLI-friendly names of all internal commands
      def internal_command_names
        internal_command_classes.map(&:command_name)
      end

      # @param command_name [String] the CLI-friendly name of the command
      # @return [Class, nil] the command class corresponding to the given name, or `nil` if the name
      #  does not correspond to an internal command
      def internal_command_for(command_name)
        klass = internal_command_classes.find { |c| c.command_name == command_name }
        # TODO: raise here if nil?
        klass
      end

      # @return [Boolean] whether or not there is an internal command with the given name
      def internal?(command_name)
        internal_command_names.include?(command_name)
      end

      # @return [Array<String>] the CLI-friendly names of all commands, internal and external
      def all_command_names
        internal_command_names + external_command_names
      end

      # @param command_name [String] the CLI-friendly name of the internal command to run
      # @param args [Array<String>] the arguments, if any, to pass to the command
      # @note This method only takes **internal** command names.
      # @return [void]
      def run!(command_name, *args)
        klass = internal_command_for command_name
        cmd = klass.new(args)
        cmd.setup!
        cmd.validate!
        cmd.run!
      end
    end
  end
end
