# frozen_string_literal: true

module KBSecret
  module Record
    # Represents a record containing a code snippet and its description.
    class Snippet < Abstract
      # @!attribute code
      #  @return [String] the code snippet
      # @!attribute description
      #  @return [String] the description of the code snippet
      data_field :code, sensitive: false
      data_field :description, sensitive: false
    end
  end
end
