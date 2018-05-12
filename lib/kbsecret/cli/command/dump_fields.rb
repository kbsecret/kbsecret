# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret dump-fields`.
      class DumpFields < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret dump-fields [options] <record>
              HELP

              o.string "-s", "--session", "the session to search in", default: :default
              o.bool "-x", "--terse", "output in field<sep>value format"
              o.string "-i", "--ifs", "separate terse pairs with this string", default: cli.ifs
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
          cli.die "No such record." unless @record
        end

        # @see Command::Abstract#run!
        def run!
          field_values = @record.data_fields.map { |f| @record.send f }
          field_pairs  = @record.data_fields.zip(field_values)

          if cli.opts.terse?
            puts field_pairs.map { |f, v| "#{f}#{cli.opts[:ifs]}#{v}" }.join "\n"
          else
            puts field_pairs.map { |f, v| "#{f}: #{v}" }.join "\n"
          end
        end
      end
    end
  end
end
