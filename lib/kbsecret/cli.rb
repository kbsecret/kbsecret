# frozen_string_literal: true

require "pastel"
require "slop"

module KBSecret
  # An encapsulation of useful methods for kbsecret's CLI.
  module CLI
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
