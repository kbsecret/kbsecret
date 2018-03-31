# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret sessions`.
      class Sessions < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret sessions [options]
              HELP

              o.bool "-a", "--show-all", "show each session in depth (i.e. metadata)"
            end
          end
        end

        # @see Command::Abstract#run!
        def run!
          Config.session_labels.each do |sess_name|
            session_hash = Config.session(sess_name)
            session      = cli.guard { KBSecret::Session[sess_name] }

            puts sess_name

            next unless cli.opts.show_all?

            if session_hash[:team]
              puts <<~DETAIL
                \tTeam: #{session_hash[:team]}
                \tSecrets root: #{session_hash[:root]} (#{session.path})
              DETAIL
            else
              puts <<~DETAIL
                \tUsers: #{session_hash[:users].join(", ")}
                \tSecrets root: #{session_hash[:root]} (#{session.path})
              DETAIL
            end
          end
        end
      end
    end
  end
end
