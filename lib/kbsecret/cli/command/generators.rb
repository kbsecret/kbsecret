# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret generators`.
      class Generators < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret generators [options]
              HELP

              o.bool "-a", "--show-all", "show each generator in depth (i.e. metadata)"
            end
          end
        end

        # @see Command::Abstract#run!
        def run!
          Config[:generators].each do |label, config|
            puts label

            next unless cli.opts.show_all?

            puts <<~DETAIL
              \tFormat: #{config[:format]}
              \tLength: #{config[:length]}
            DETAIL
          end
        end
      end
    end
  end
end
