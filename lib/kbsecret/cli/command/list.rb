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
              o.bool "-D", "--sort-date", "sort records by date (oldest to newest)"
              o.bool "-A", "--sort-alphabetical", "sort records by label"
            end

            cli.ensure_type! if cli.opts[:type]
            cli.ensure_session!
          end
        end

        # @see Command::Abstract#setup!
        def setup!
          @records = cli.session.records TYPE_ALIASES[cli.opts[:type]]
        end

        # @see Command::Abstract#validate!
        def validate!
          if cli.opts.sort_date? && cli.opts.sort_alphabetical?
            cli.die "Only one sort flag may be used at once."
          end
        end

        # @see Command::Abstract#setup!
        def run!
          if cli.opts.sort_date?
            @records.sort_by!(&:timestamp)
          elsif cli.opts.sort_alphabetical?
            @records.sort_by!(&:label)
          end

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
