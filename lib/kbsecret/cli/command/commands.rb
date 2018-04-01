# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret commands`.
      class Commands < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret commands [options]
              HELP

              o.bool "-e", "--external-only", "list only external commands"
              o.bool "-i", "--internal-only", "list only internal commands"
            end
          end
        end

        # @see Command::Abstract#run!
        def run!
          cmds = if cli.opts.external_only?
                   Command.external_command_names
                 elsif cli.opts.internal_only?
                   Command.internal_command_names
                 else
                   Command.all_command_names
                 end

          puts cmds.join "\n"
        end
      end
    end
  end
end
