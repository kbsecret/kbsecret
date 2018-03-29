# frozen_string_literal: true

require "base64"

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret stash-file`.
      class StashFile < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret stash-file <record> [file]
              HELP

              o.string "-s", "--session", "the session to add to", default: :default
              o.bool "-f", "--force", "force creation (ignore overwrites, etc.)"
              o.bool "-b", "--base64", "encode the file as base64"
            end

            cli.dreck do
              string :label
              string :filename
            end

            cli.ensure_session!
          end
        end

        # @see Command::Abstract#setup!
        def setup!
          @label = cli.args[:label]
          @filename = cli.args[:filename]
        end

        # @see Command::Abstract#validate!
        def validate!
          if cli.session.record?(@label) && !cli.opts.force?
            cli.die "Refusing to overwrite a record without --force."
          end

          cli.die "No such file." unless File.file?(@filename) || @filename == "-"
        end

        # @see Command::Abstract#run!
        def run!
          contents = if @filename == "-"
                       STDIN.read
                     elsif File.file?(@filename)
                       File.read(@filename)
                     end

          contents = Base64.encode64(contents) if cli.opts.base64?

          cli.guard { cli.session.add_record(:unstructured, @label, contents) }
        end
      end
    end
  end
end
