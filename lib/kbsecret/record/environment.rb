require "shellwords"

module KBSecret
  module Record
    class Environment < Abstract
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

      def variable
        @data[:environment][:variable]
      end

      def variable=(var)
        @data[:environment][:variable] = var
        sync!
      end

      def value
        @data[:environment][:value]
      end

      def value=(val)
        @data[:environment][:value] = val
        sync!
      end

      def to_assignment
        "#{variable}=#{value}"
      end

      def to_export
        "export #{to_assignment}"
      end
    end
  end
end
