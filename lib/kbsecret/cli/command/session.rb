# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret session`.
      class Session < Abstract
        # The list of subcommands supported by `kbsecret session`.
        SUBCOMMANDS = %w[new rm].freeze

        def initialize(argv)
          super(argv) do |cli|
            cli.slop cmds: SUBCOMMANDS do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret session [options] <new|rm> <label>
              HELP

              o.string "-t", "--team", "the team to create the session under"
              o.array "-u", "--users", "the Keybase users", default: [Keybase::Local.current_user]
              o.string "-r", "--root", "the secret root directory"
              o.bool "-c", "--create-team", "create the Keybase team if it does not exist"
              o.bool "-f", "--force", "force creation (ignore overwrites, etc.)"
              o.bool "-n", "--no-notify", "do not send a notification to session members"
              o.bool "-d", "--delete", "unlink the session in addition to deconfiguration"
            end

            cli.dreck do
              string :command
              string :session
            end

            cli.ensure_session! :argument if cli.args[:command] == "rm"
          end
        end

        # @see Command::Abstract#setup!
        def setup!
          @label = cli.args[:session]
          @subcmd = cli.args[:command]
        end

        # @see Command::Abstract#validate!
        def validate!
          cli.die "Unknown subcommand: #{@subcmd}." unless SUBCOMMANDS.include?(@subcmd)
        end

        # @see Command::Abstract#run!
        def run!
          case @subcmd
          when "new"
            new_session
          when "rm"
            rm_session
          end
        end

        # @api private
        # @return [void]
        def new_session
          if Config.session?(@label) && !cli.opts.force?
            cli.die "Refusing to overwrite a session without --force."
          end

          if cli.opts[:team]
            teams = Keybase::Local::Team.list_self_memberships.teams

            unless teams.map(&:fq_name).include?(cli.opts[:team])
              if cli.opts.create_team?
                cli.guard do
                  Keybase::Local::Team.create_team cli.opts[:team]
                  Keybase::Local::Team.add_members cli.opts[:team], users: [{
                    username: Keybase::Local.current_user,
                    role: "admin",
                  }]
                end
              else
                cli.die "No such team (either nonexistent or non-member)."
              end
            end

            Config.configure_session(@label, team: cli.opts[:team], root: @label)
          else
            cli.die "Missing `-r', `--root' option." unless cli.opts[:root]

            cli.opts[:users].each do |user|
              cli.die "Nonexistent Keybase user: #{user}." unless Keybase::API.user? user
            end

            unless cli.opts[:users].include? Keybase::Local.current_user
              cli.warn "You didn't include yourself in the user list, but I'll add you."
              cli.opts[:users] << Keybase::Local.current_user
            end

            Config.configure_session(@label, users: cli.opts[:users], root: cli.opts[:root])

            unless cli.opts.no_notify? && cli.opts[:users] != [Keybase::Local.current_user]
              users = cli.opts[:users].join(",")

              Keybase::Local::Chat.send_message cli.opts[:users], <<~MESSAGE
                You've been added to a KBSecret session!

                To access this session, please run the following:

                ```
                  $ kbsecret session new -r '#{cli.opts[:root]}' -u #{users} <label>
                ```

                If you don't have KBSecret installed, you can install it from `gem`:

                ```
                  $ gem install kbsecret
                ```
              MESSAGE
            end
          end
        end

        # @api private
        # @return [void]
        def rm_session
          cli.session.unlink! if cli.opts.delete?
          Config.deconfigure_session @label
        end
      end
    end
  end
end
