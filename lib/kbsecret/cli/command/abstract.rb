# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # Represents an abstract {KBSecret} command that can be subclassed to produce a more
      # useful command. {KBSecret::CLI::Command::List} is an example of this.
      # @abstract
      class Abstract
        # @return [CLI] the CLI state corresponding to the command
        attr_reader :cli

        # @return [String] the command's CLI-friendly name
        # @example
        #  KBSecret::CLI::Command::StashFile # => "stash-file"
        def self.command_name
          name.split("::")
              .last
              .gsub(/([^A-Z])([A-Z]+)/, '\1-\2')
              .downcase
        end

        # @param argv [String] the arguments to call the command with
        def initialize(argv)
          @cli = CLI.create(argv) { |_o| nil }
          @cli.guard do
            yield @cli if block_given?
          end
        end

        # Sets up any state used by the command. Implemented by children.
        # @abstract
        def setup!
          nil
        end

        # Runs any validation checks required by the command. Implemented by children.
        # @abstract
        def validate!
          nil
        end

        # Runs the command. Implemented by children.
        # @abstract
        def run!
          nil
        end
      end
    end
  end
end
