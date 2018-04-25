# frozen_string_literal: true

require "tempfile"
require "base64"

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret stash-edit`.
      class StashEdit < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret stash-edit [options] <record>
              HELP

              o.string "-s", "--session", "the session to search in", default: :default
              o.bool "-b", "--base64", "base64 decode the file before editing, and encode it after"
            end

            cli.dreck do
              string :label
            end

            cli.ensure_session!
          end
        end

        # @see Command::Abstract#setup!
        def setup!
          @record = cli.session[cli.args[:label]]
        end

        # @see Command::Abstract#validate!
        def validate!
          cli.die "Missing $EDITOR." unless ENV["EDITOR"]
          cli.die "No such unstructured record." unless @record && @record.type == :unstructured
        end

        # @see Command::Abstract#run!
        def run!
          tempfile = Tempfile.new(@record.label)
          contents = cli.opts.base64? ? Base64.decode64(@record.text) : @record.text

          tempfile.write(contents)
          tempfile.flush

          system "#{ENV["EDITOR"]} #{tempfile.path}"

          tempfile.rewind

          contents     = cli.opts.base64? ? Base64.encode64(tempfile.read) : tempfile.read
          @record.text = contents
        ensure
          tempfile.close
          tempfile&.unlink
        end
      end
    end
  end
end
