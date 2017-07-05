# frozen_string_literal: true

require "colored2"
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
    #      o.string "-s", "--session", "session label"
    #      o.bool "-f", "--foo", "whatever"
    #    end
    #
    #    dreck do
    #      string :name
    #    end
    #
    #    ensure_session!
    #  end
    #
    #  cmd.opts # => Slop::Result
    #  cmd.args # => Dreck::Result
    def initialize(&block)
      @trailing = ARGV
      @opts = nil
      @args = nil
      instance_eval(&block)
    rescue => e
      self.class.die "#{e.to_s.capitalize}."
    end

    # Parse options for a kbsecret utility, adding some default options for
    #  introspection, verbosity, and help output.
    # @param cmds [Array<String>] additional commands to print in `--introspect-flags`
    # @param errors [Boolean] whether or not to produce Slop errors
    # @return [Slop::Result] the result of argument parsing
    # @note This should be called within the block passed to {#initialize}.
    def slop(cmds: [], errors: true)
      @opts = Slop.parse suppress_errors: !errors do |o|
        o.separator "Options:"

        yield o

        o.bool "-V", "--verbose", "produce more verbose output"
        o.bool "-w", "--no-warn", "suppress warning messages"

        o.on "-h", "--help", "show this help message" do
          puts o
          exit
        end

        o.on "--introspect-flags", "dump recognized flags and subcommands" do
          comp = o.options.flat_map(&:flags) + cmds
          puts comp.join "\n"
          exit
        end
      end

      @trailing = @opts.args
    end

    # Parse trailing arguments for a kbsecret utility, using the elements remaining
    #  after options have been removed and interpreted via {#slop}.
    # @param errors [Boolean] whether or not to produce (strict) Dreck errors
    # @note *If* {#slop} is called, it must be called before this.
    def dreck(errors: true, &block)
      @args = Dreck.parse @trailing, strict: errors do
        instance_eval(&block)
      end
    end

    # Ensure that a session passed in as an option or argument already exists
    #   (i.e., is already configured).
    # @param where [Symbol] Where to look for the session label to test.
    #   If `:option` is passed, then the session is expected to be the value of
    #   the `--session` option. If `:argument` is passed, then the session is expected
    #   to be in the argument list labeled as `:argument` by Dreck.
    # @return [void]
    # @raise [RuntimeError] if the expected session is not configured.
    # @note {#slop} and {#dreck} should be called before this, depending on whether
    #   options or arguments are being tested for a valid session.
    def ensure_session!(where = :option)
      label = where == :option ? @opts[:session] : @args[:session]
      raise "Unknown session: '#{label}'" unless Config.session? label
    end

    # Print an informational message if verbose output has been enabled.
    # @param msg [String] the message to print
    # @return [void]
    def info(msg)
      return unless @opts.verbose?
      STDERR.puts "#{"Info".green}: #{msg}"
    end

    # Print a warning message unless warnings have been suppressed.
    # @param msg [String] the message to print
    # @return [void]
    def warn(msg)
      return if @opts.no_warn?
      STDERR.puts "#{"Warning".yellow}: #{msg}"
    end

    # Print an error message and terminate.
    # @param msg [String] the message to print
    # @return [void]
    # @note This method does not return!
    def die(msg)
      pretty = "#{"Fatal".red}: #{msg}"
      abort pretty
    end

    class << self
      # Print an error message and terminate.
      # @param msg [String] the message to print
      # @return [void]
      # @note This method does not return!
      def die(msg)
        pretty = "#{"Fatal".red}: #{msg}"
        abort pretty
      end

      # Finds a reasonable default field separator by checking the environment first
      #  and then falling back to ":".
      # @return [String] the field separator
      def ifs
        ENV["IFS"] || ":"
      end
    end
  end
end
