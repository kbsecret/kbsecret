# frozen_string_literal: true

require "tty-prompt"

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret rm`.
      class Rm < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret rm [options] <record [record ...]>
              HELP

              o.string "-s", "--session", "the session containing the record", default: :default
              o.bool "-i", "--interactive", "ask for confirmation before deleting"
            end

            cli.dreck do
              list :string, :labels
            end

            cli.ensure_session!
          end
        end

        # @see Command::Abstract#setup!
        def setup!
          @selected_records = cli.session.records.select do |record|
            cli.args[:labels].include? record.label
          end
        end

        # @see Command::Abstract#validate!
        def validate!
          cli.die "No such record(s)." if @selected_records.empty?
        end

        # @see Command::Abstract#run!
        def run!
          $VERBOSE = nil # tty-prompt blasts us with irrelevant warnings on 2.4

          tty = TTY::Prompt.new

          confirm = if cli.opts.interactive?
                      tty.yes?("Delete '#{selected_records.join(", ")}'?")
                    else true
                    end

          @selected_records.each { |r| cli.session.delete_record(r.label) } if confirm
        end
      end
    end
  end
end
