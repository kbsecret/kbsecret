# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret todo`.
      class Todo < Abstract
        # The list of subcommands supported by `kbsecret todo`.
        SUBCOMMANDS = %w[start suspend complete].freeze

        def initialize(argv)
          super(argv) do |cli|
            cli.slop cmds: SUBCOMMANDS do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret todo <start|suspend|complete> <record>
              HELP

              o.string "-s", "--session", "the session to search in", default: :default
            end

            cli.dreck do
              string :command
              string :label
            end

            cli.ensure_session!
          end
        end

        # @see Command::Abstract#setup!
        def setup!
          @todo = cli.session[cli.args[:label]]
          @subcmd = cli.args[:command]
        end

        # @see Command::Abstract#validate!
        def validate!
          cli.die "No such todo record: #{@todo}." unless @todo && @todo.type == :todo
          cli.die "Unknown subcommand: #{@subcmd}." unless SUBCOMMANDS.include?(@subcmd)
        end

        # @see Command::Abstract#setup!
        def run!
          case @subcmd
          when "start" then start_todo
          when "suspend" then suspend_todo
          when "complete" then complete_todo
          end
        end

        # Starts the todo associated with the current invocation, unless already started.
        # @return [void]
        # @api private
        def start_todo
          cli.die "That task is already started!" if @todo.started?
          @todo.start!
          puts "#{@todo.label}: '#{@todo.todo}' marked as started at #{@todo.start}"
        end

        # Suspends the todo associated with the current invocation, unless already suspended.
        # @return [void]
        # @api private
        def suspend_todo
          cli.die "That task is already suspended!" if @todo.suspended?
          @todo.suspend!
          puts "#{@todo.label}: '#{@todo.todo}' marked as suspended at #{@todo.stop}"
        end

        # Completes the todo associated with the current invocation, unless already completed.
        # @return [void]
        # @api private
        def complete_todo
          cli.die "That task is already completed!" if @todo.completed?
          @todo.complete!
          puts "#{@todo.label}: '#{@todo.todo}' marked as completed at #{@todo.stop}"
        end
      end
    end
  end
end
