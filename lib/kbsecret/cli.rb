# frozen_string_literal: true

require "pastel"

module KBSecret
  # An encapsulation of useful methods for kbsecret's CLI.
  module CLI
    class << self
      # The pastel object used to generate colorful output.
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
    end
  end
end
