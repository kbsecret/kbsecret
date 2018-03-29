# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret raw-edit`.
      class RawEdit < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret raw-edit [options] <record>
              HELP

              o.string "-s", "--session", "the session to search in", default: :default
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
          cli.die "Missing $EDITOR." unless ENV["EDITOR"]
          cli.die "No such record." unless @record
        end

        # @see Command::Abstract#run!
        def run!
          Process.spawn("#{ENV["EDITOR"]} #{@record.path}")
          @record.sync! # just to bump the timestamp
        end
      end
    end
  end
end
