# frozen_string_literal: true

module KBSecret
  module Record
    # Represents a record containing a code snippet and its description.
    class Snippet < Abstract
      data_field :code, sensitive: false
      data_field :description, sensitive: false

      # @param session [Session] the session to associate with
      # @param label [Symbol] the new record's label
      # @param code [String] the code
      # @param description [String] a description of the code
      def initialize(session, label, code, description)
        super(session, label)

        @data = {
          snippet: {
            code: code,
            description: description,
          },
        }
      end
    end
  end
end
