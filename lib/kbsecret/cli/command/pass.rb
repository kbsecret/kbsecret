# frozen_string_literal: true

require "clipboard"

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret pass`.
      class Pass < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret pass [options] <record>
              HELP

              o.string "-s", "--session", "the session to search in", default: :default
              o.bool "-c", "--clipboard", "dump the password in the clipboard"
              o.bool "-C", "--no-clear", "don't clear the password from the clipboard"
            end

            cli.dreck do
              string :label
            end

            cli.ensure_session!
          end
        end

        # @see Command::Abstract#setup!
        def setup!
          @record = cli.session[cli.args[:label]]
        end

        # @see Command::Abstract#validate!
        def validate!
          cli.die "No such login record." unless @record && @record.type == :login
        end

        # @see Command::Abstract#run!
        def run!
          if cli.opts.clipboard?
            Clipboard.copy @record.password

            unless cli.opts.no_clear?
              fork do
                Process.daemon
                sleep 10
                Clipboard.clear
              end
            end
          else
            puts @record.password
          end
        end
      end
    end
  end
end
