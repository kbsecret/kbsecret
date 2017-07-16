# frozen_string_literal: true

module KBSecret
  module Record
    # Represents a record containing a login (username, password) pair.
    class Login < Abstract
      # @!attribute username
      #  @return [String] the username
      # @!attribute password
      #  @return [String] the password
      data_field :username, sensitive: false
      data_field :password
    end
  end
end
