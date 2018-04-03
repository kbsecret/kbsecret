# frozen_string_literal: true

module KBSecret
  class CLI
    module Command
      # The implementation of `kbsecret cp`.
      class Cp < Abstract
        def initialize(argv)
          super(argv) do |cli|
            cli.slop do |o|
              o.banner = <<~HELP
                Usage:
                  kbsecret cp [options] <source> <destination> <record [record ...]>
              HELP

              o.bool "-f", "--force", "force copying (ignore overwrites)"
              o.bool "-m", "--move", "delete the record after copying"
            end

            cli.dreck do
              string :src_sess
              string :dst_sess
              list :string, :labels
            end
          end
        end

        # @see Command::Abstract#run!
        def run!
          src_sess = KBSecret::Session[cli.args[:src_sess]]
          dst_sess = KBSecret::Session[cli.args[:dst_sess]]

          selected_records = src_sess.records.select { |r| cli.args[:labels].include?(r.label) }
          cli.die "No such record(s)." if selected_records.empty?

          overlaps = dst_sess.record_labels & selected_records.map(&:label)

          # the code below actually handles the overwriting if necessary, but we fail early here
          # for friendliness and to avoid half-copying the selected records
          unless overlaps.empty? || cli.opts.force?
            cli.die "Refusing to overwrite existing record(s) without --force."
          end

          selected_records.each do |record|
            dst_sess.import_record(record, overwrite: cli.opts.force?)
            src_sess.delete_record(record.label) if cli.opts.move?
          end
        end
      end
    end
  end
end
