# frozen_string_literal: true

module KBSecret
  module Record
    # Represents a record containing a login (username, password) pair.
    class Login < Abstract
      data_field :username, sensitive: false
      data_field :password

      # @param session [Session] the session to associate with
      # @param label [Symbol] the new record's label
      # @param user [String] the new record's username
      # @param pass [String] the new record's password
      def initialize(session, label, user, pass)
        super(session, label)

        @data = {
          login: {
            username: user,
            password: pass,
          },
        }
      end
    end
  end
end
