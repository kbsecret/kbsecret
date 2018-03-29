# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret generator`.
      class Generator < Abstract
        # The list of subcommands supported by `kbsecret generator`.
        SUBCOMMANDS = %w[new rm].freeze

        def initialize(argv)
          super(argv) do |cli|
            cli.slop cmds: SUBCOMMANDS do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret generator [options] <new|rm> <generator>
              HELP

              o.string "-F", "--format", "the format of the secrets generated", default: "hex"
              o.integer "-l", "--length", "the length, in bytes, of the secrets generated",
                        default: 16
              o.bool "-f", "--force", "force generator creation (ignore overwrite)"
            end

            cli.dreck do
              string :command
              string :generator
            end

            cli.ensure_generator! :argument if cli.args[:command] == "rm"
          end
        end

        # @see Command::Abstract#setup!
        def setup!
          @subcmd = cli.args[:command]
        end

        # @see Command::Abstract#validate!
        def validate!
          cli.die "Unknown subcommand: #{@subcmd}." unless SUBCOMMANDS.include?(@subcmd)
        end

        # @see Command::Abstract#run!
        def run!
          case @subcmd
          when "new"
            if Config.generator?(cli.args[:generator]) && !cli.opts.force?
              cli.die "Refusing to overwrite an existing generator without --force."
            end

            Config.configure_generator(cli.args[:generator],
                                       format: cli.opts[:format],
                                       length: cli.opts[:length])
          when "rm"
            Config.deconfigure_generator(cli.args[:generator])
          end
        end
      end
    end
  end
end
