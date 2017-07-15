# frozen_string_literal: true

require "shellwords"

module KBSecret
  module Record
    # Represents a record containing an environment variable and value.
    class Environment < Abstract
      data_field :variable, sensitive: false
      data_field :value

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
