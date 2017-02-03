module KBSecret
  module Record
    # Represents a record containing unstructured text.
    class Unstructured < Abstract
      # @param session [Session] the session to associate with
      # @param label [Symbol] the new record's label
      # @param text [String] the new record's unstructured text
      def initialize(session, label, text)
        super(session, label)

        @data = {
          text: text
        }
      end

      # @return [String] the record's unstructured text
      def text
        @data[:text]
      end

      # @param new_text [String] the new text to insert into the record
      # @return [void]
      # @note Triggers a record sync; see {Abstract#sync!}.
      def text=(new_text)
        @data[:text] = new_text
        sync!
      end
    end
  end
end
