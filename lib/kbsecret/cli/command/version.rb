# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret version`.
      class Version < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret version
              HELP
            end
          end
        end

        # @see Command::Abstract#run!
        def run!
          puts "kbsecret version #{KBSecret::VERSION}."
        end
      end
    end
  end
end
