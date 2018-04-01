# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret types`.
      class Types < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret types
              HELP
            end
          end
        end

        # @see Command::Abstract#run!
        def run!
          puts KBSecret::Record.record_types.join("\n")
        end
      end
    end
  end
end
