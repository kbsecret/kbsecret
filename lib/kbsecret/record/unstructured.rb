module KBSecret
  module Record
    # Represents a record containing unstructured text.
    class Unstructured < Abstract
      data_field :text

      # @param session [Session] the session to associate with
      # @param label [Symbol] the new record's label
      # @param text [String] the new record's unstructured text
      def initialize(session, label, text)
        super(session, label)

        @data = {
          unstructured: {
            text: text,
          }
        }
      end
    end
  end
end
