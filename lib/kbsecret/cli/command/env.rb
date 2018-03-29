# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret env`.
      class Env < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret env [options] <record [record ...]>
              HELP

              o.string "-s", "--session", "the session to search in", default: :default
              o.bool "-a", "--all", "retrieve all environment records, not just listed ones"
              o.bool "-v", "--value-only", "print only the environment value, not the key"
              o.bool "-n", "--no-export", "print only VAR=val keypairs without `export`"
              o.bool "-u", "--unescape-plus", "escape any pluses in the variable and/or value"
            end

            unless cli.opts.all?
              cli.dreck do
                list :string, :labels
              end
            end

            cli.ensure_session!
          end
        end

        # @see Command::Abstract#setup!
        def setup!
          @records = if cli.opts.all?
                       cli.session.records :environment
                     else
                       cli.session.records(:environment).select do |record|
                         cli.args[:labels].include? record.label
                       end
                     end
        end

        # @see Command::Abstract#validate!
        def validate!
          cli.die "No such record(s)." if @records.empty?
        end

        # @see Command::Abstract#run!
        def run!
          env_output = if cli.opts.no_export?
                         @records.map(&:to_assignment).join(" ")
                       elsif cli.opts.value_only?
                         @records.map(&:value).join("\n")
                       else
                         @records.map(&:to_export).join("\n")
                       end

          env_output.gsub!("\\+", "+") if cli.opts.unescape_plus?

          puts env_output
        end
      end
    end
  end
end
