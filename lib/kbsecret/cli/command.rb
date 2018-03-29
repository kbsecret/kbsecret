# frozen_string_literal: true

# we have to require abstract first because ruby's module resolution is bad
require_relative "command/abstract"
Dir[File.join(__dir__, "command/*.rb")].each { |t| require_relative t }

module KBSecret
  class CLI
    # The namespace for {KBSecret}'s internal commands.
    module Command
      module_function

      # @return [Array<Class>] the class objects of all non-abstract commands
      def command_classes
        klasses = constants.map(&Command.method(:const_get)).grep(Class)
        klasses.delete(Command::Abstract)
        klasses
      end

      # @return [Array<String>] the CLI-friendly names of all commands
      def command_names
        command_classes.map(&:command_name)
      end

      # @param command_name [String] the CLI-friendly name of the command
      # @return [Class, nil] the command class corresponding to the given name, or `nil`
      def command_for(command_name)
        klass = command_classes.find { |c| c.command_name == command_name }
        # TODO: raise here if nil?
        klass
      end

      # @param command_name [String] the CLI-friendly name of the command to run
      # @param args [Array<String>] the arguments, if any, to pass to the command
      # @return [void]
      def run!(command_name, *args)
        klass = command_for command_name
        cmd = klass.new(args)
        cmd.setup!
        cmd.validate!
        cmd.run!
      end
    end
  end
end
