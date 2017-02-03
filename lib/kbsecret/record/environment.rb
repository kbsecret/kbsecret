require "shellwords"

module KBSecret
  module Record
    # Represents a record containing an environment variable and value.
    class Environment < Abstract
      # @param session [Session] the session to associate with
      # @param label [Symbol] the new record's label
      # @param variable [String] the new record's variable
      # @param value [String] the new record's value
      def initialize(session, label, variable, value)
        super(session, label)

        value = value.shellescape
        variable = variable.shellescape

        @data = {
          environment: {
            variable: variable,
            value: value,
          },
        }
      end

      # @return [String] the record's variable
      def variable
        @data[:environment][:variable]
      end

      # @param var [String] the new variable to insert into the record
      # @return [void]
      # @note Triggers a record sync; see {Abstract#sync!}.
      def variable=(var)
        @data[:environment][:variable] = var
        sync!
      end

      # @return [String] the record's value
      def value
        @data[:environment][:value]
      end

      # @param val [String] the new value to insert into the record
      # @return [void]
      # @note Triggers a record sync; see {Abstract#sync!}.
      def value=(val)
        @data[:environment][:value] = val
        sync!
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
