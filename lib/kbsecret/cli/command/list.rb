# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret list`.
      class List < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret list [options]
              HELP

              o.string "-s", "--session", "the session to list from", default: :default
              o.string "-t", "--type", "the type of secrets to list", default: nil
              o.bool "-a", "--show-all", "show everything in each secret (i.e. metadata)"
            end

            cli.ensure_type! if cli.opts[:type]
            cli.ensure_session!
          end
        end

        # @see Command::Abstract#setup!
        def setup!
          @records = cli.session.records cli.opts[:type]
        end

        # @see Command::Abstract#setup!
        def run!
          @records.each do |record|
            puts record.label

            next unless cli.opts.show_all?

            puts <<~DETAIL
              \tType: #{record.type}
              \tLast changed: #{Time.at(record.timestamp)}
              \tRaw data: #{record.data}
            DETAIL
          end
        end
      end
    end
  end
end
