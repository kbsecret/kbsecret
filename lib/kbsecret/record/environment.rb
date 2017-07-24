# frozen_string_literal: true

require "shellwords"

module KBSecret
  module Record
    # Represents a record containing an environment variable and value.
    class Environment < Abstract
      # @!attribute variable
      #  @return [String] the environment variable
      # @!attribute value
      #  @return [String] the value of the environment value
      data_field :variable, sensitive: false
      data_field :value

      # @return [void]
      # @see Abstract#populate_internal_fields
      def populate_internal_fields
        defer_sync implicit: false do
          self.variable = variable.shellescape
          self.value = value.shellescape
        end
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
