module KBSecret
  module Record
    # Represents a record containing a login (username, password) pair.
    class Login < Abstract
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

      # @return [String] the record's username
      def username
        @data[:login][:username]
      end

      # @param user [String] the new username to insert into the record
      # @return [void]
      # @note Triggers a record sync; see {Abstract#sync!}.
      def username=(user)
        @data[:login][:username] = user
        sync!
      end

      # @return [String] the record's password
      def password
        @data[:login][:password]
      end

      # @param pass [String] the new password to insert into the record
      # @return [void]
      # @note Triggers a record sync; see {Abstract#sync!}.
      def password=(pass)
        @data[:login][:password] = pass
        sync!
      end
    end
  end
end
