module KBSecret
  module Record
    class Unstructured < Abstract
      def initialize(session, label, text)
        super(session, label)

        @data = {
          text: text
        }
      end

      def text
        @data[:text]
      end

      def text=(new_text)
        @data[:text] = new_text
        sync!
      end
    end
  end
end
