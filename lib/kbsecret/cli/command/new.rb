#!/usr/bin/env ruby
# frozen_string_literal: true

require "abbrev"
require "tty-prompt"

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret new`.
      class New < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret new [options] <type> <label>
              HELP

              o.string "-s", "--session", "the session to contain the record", default: :default
              o.bool "-f", "--force", "force creation (ignore overwrites, etc.)"
              o.bool "-e", "--echo", "echo input to tty (only affects interactive input)"
              o.bool "-G", "--generate", "generate secret fields (interactive only)"
              o.string "-g", "--generator", "the generator to use for secret fields",
                       default: :default
              o.bool "-x", "--terse", "read fields from input in a terse format"
              o.string "-i", "--ifs", "separate terse fields with this string", default: CLI.ifs
            end

            cli.dreck do
              string :type
              string :label
            end

            cli.ensure_generator!
            cli.ensure_type! :argument
            cli.ensure_session!
          end
        end

        # @see Command::Abstract#setup!
        def setup!
          @label = cli.args[:label]
          @type  = TYPE_ALIASES[cli.args[:type]]
        end

        # @see Command::Abstract#validate!
        def validate!
          # the code below actually handles the overwriting if necessary, but we fail early here
          # for friendliness and to avoid prompting the user for input unnecessarily
          if cli.session.record?(@label) && !cli.opts.force?
            cli.die "Refusing to overwrite a record without --force."
          end
        end

        # @see Command::Abstract#run!
        def run!
          generator = KBSecret::Generator.new(cli.opts[:generator]) if cli.opts.generate?

          fields = if cli.opts.terse?
                     CLI.stdin.read.chomp.split cli.opts[:ifs]
                   else
                     prompt = TTY::Prompt.new
                     klass = Record.class_for(@type)
                     klass.external_fields.map do |field|
                       if cli.opts.generate? && klass.sensitive?(field)
                         generator.secret
                       else
                         prompt.ask "#{field.capitalize}?",
                                    echo: !klass.sensitive?(field) || cli.opts.echo?
                       end
                     end
                   end

          cli.session.add_record @type, @label, *fields, overwrite: cli.opts.force?
        end
      end
    end
  end
end
