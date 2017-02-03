module KBSecret
  module Record
    class Login < Abstract
      def initialize(session, label, user, pass)
        super(session, label)

        @data = {
          login: {
            username: user,
            password: pass,
          },
        }
      end

      def username
        @data[:login][:username]
      end

      def username=(user)
        @data[:login][:username] = user
        sync!
      end

      def password
        @data[:login][:password]
      end

      def password=(pass)
        @data[:login][:password] = pass
        sync!
      end
    end
  end
end
