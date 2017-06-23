# frozen_string_literal: true

require "pastel"
require "slop"
require "dreck"

module KBSecret
  # An encapsulation of useful methods for kbsecret's CLI.
  class CLI
    # @return [Slop::Result] the result of option parsing
    attr_reader :opts

    # @return [Dreck::Result] the result of trailing argument parsing
    attr_reader :args

    # Encapsulate both the options and trailing arguments passed to a `kbsecret` command.
    # @example
    #  cmd = KBSecret::CLI.new do
    #    slop do |o|
    #      o.bool "-f", "--foo", "whatever"
    #    end
    #
    #    dreck do
    #      string :name
    #    end
    #  end
    #
    #  cmd.opts # => Slop::Result
    #  cmd.args # => Dreck::Result
    def initialize(&block)
      instance_eval(&block)
    end

    # Parse options for a kbsecret utility, adding some default options for
    #  introspection and help output.
    # @param cmds [Array<String>] additional commands to print in `--introspect-flags`
    # @param errors [Boolean] whether or not to produce Slop errors
    # @return [Slop::Result] the result of argument parsing
    # @note This should be called within the block passed to {initialize}.
    def slop(cmds: [], errors: false)
      @opts = Slop.parse suppress_errors: !errors do |o|
        yield o

        o.on "-h", "--help" do
          puts o
          exit
        end

        o.on "--introspect-flags" do
          comp = o.options.flat_map(&:flags) + cmds
          puts comp.join "\n"
          exit
        end
      end

      @trailing = @opts.args
    end

    # Parse trailing arguments for a kbsecret utility, using the elements remaining
    #  after options have been removed and interpreted via {slop}.
    # @param errors [Boolean] whether or not to produce (strict) Dreck errors
    # @note This should be called in the block passed to {initialize}, and **only**
    #  after a successful {slop} call.
    def dreck(errors: false, &block)
      @args = Dreck.parse @trailing, strict: errors do
        instance_eval(&block)
      end
    end

    class << self
      # The pastel object used to generate colorful output.
      # @api private
      PASTEL = Pastel.new

      # Print an error message and terminate.
      # @param msg [String] the message to print
      # @return [void]
      # @note This method does not return!
      def die(msg)
        pretty = "#{PASTEL.bright_red("Fatal")}: #{msg}"
        abort pretty
      end

      # Instantiate a session if it exists, and terminate otherwise.
      # @param sess_label [String, Symbol] the session label to instantiate
      # @return [void]
      # @note This method does not return if the given session is not configured!
      def ensure_session(sess_label)
        die "Unknown session: '#{sess_label}'." unless Config.session? sess_label

        Session.new label: sess_label
      end

      # Parse arguments for a kbsecret utility, adding some default options for
      #  introspection and help output.
      # @param cmds [Array<String>] additional commands to print in `--introspect-flags`
      # @param errors [Boolean] whether or not to produce Slop errors
      # @return [Slop::Result] the result of argument parsing
      # @deprecated Use {#initialize} instead.
      def slop(cmds: [], errors: false)
        Slop.parse suppress_errors: !errors do |o|
          yield o

          o.on "-h", "--help" do
            puts o
            exit
          end

          o.on "--introspect-flags" do
            comp = o.options.flat_map(&:flags) + cmds
            puts comp.join "\n"
            exit
          end
        end
      end
    end
  end
end
