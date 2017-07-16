# frozen_string_literal: true

module KBSecret
  module Record
    # Represents a record containing unstructured text.
    class Unstructured < Abstract
      # @!attribute text
      #  @return [String] the unstructured text of the record
      data_field :text, sensitive: false
    end
  end
end
