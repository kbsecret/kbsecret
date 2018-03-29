# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret login`.
      class Login < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret login [options] <record [record ...]>
              HELP

              o.string "-s", "--session", "the session to search in", default: :default
              o.bool "-a", "--all", "retrieve all login records, not just listed ones"
              o.bool "-x", "--terse", "output in label<sep>username<sep>password format"
              o.string "-i", "--ifs", "separate terse fields with this string", default: CLI.ifs
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
                       cli.session.records :login
                     else
                       cli.session.records(:login).select do |record|
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
          @records.each do |record|
            if cli.opts.terse?
              fields = %i[label username password].map { |m| record.send(m) }
              puts fields.join(cli.opts[:ifs])
            else
              puts <<~DETAIL
                Label: #{record.label}
                \tUsername: #{record.username}
                \tPassword: #{record.password}
              DETAIL
            end
          end
        end
      end
    end
  end
end
