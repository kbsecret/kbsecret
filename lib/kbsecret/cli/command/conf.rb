# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret conf`.
      class Conf < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage: kbsecret conf [options]
              HELP

              o.bool "-c", "--commands", "open the commands config (commands.ini)"
              o.bool "-d", "--directory", "print the path to the config directory"
              o.bool "-r", "--record-directory", "print the path to the custom record directory"
            end
          end
        end

        # @see Command::Abstract#validate!
        def validate!
          cli.die "Missing $EDITOR." unless ENV["EDITOR"]
        end

        # @see Command::Abstract#run!
        def run!
          if cli.opts.commands?
            exec "#{ENV["EDITOR"]} #{Config::COMMAND_CONFIG_FILE}"
          elsif cli.opts.directory?
            puts Config::CONFIG_DIR
          elsif cli.opts.record_directory?
            puts Config::CUSTOM_TYPES_DIR
          else
            exec "#{ENV["EDITOR"]} #{Config::CONFIG_FILE}"
          end
        end
      end
    end
  end
end
