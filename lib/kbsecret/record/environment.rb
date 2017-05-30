# frozen_string_literal: true

require "shellwords"

module KBSecret
  module Record
    # Represents a record containing an environment variable and value.
    class Environment < Abstract
      data_field :variable
      data_field :value

      # @param session [Session] the session to associate with
      # @param label [Symbol] the new record's label
      # @param variable [String] the new record's variable
      # @param value [String] the new record's value
      def initialize(session, label, variable, value)
        super(session, label)

        @data = {
          environment: {
            variable: variable.shellescape,
            value: value.shellescape,
          },
        }
      end

      # @return [String] a sh-style environment assignment
      def to_assignment
        "#{variable}=#{value}"
      end

      # @return [String] a sh-style environment export line
      def to_export
        "export #{to_assignment}"
      end
    end
  end
end
