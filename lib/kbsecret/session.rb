module KBSecret
  class Session
    attr_reader :label
    attr_reader :config
    attr_reader :directory
    attr_reader :records

    def initialize(label: :default)
      @label = label
      @config = Config.session(label.to_sym)

      @directory = rel_path config[:root], mkdir: true
      @records = load_records!
    end

    def record_labels
      records.map(&:label)
    end

    def add_record(type, label, *args)
      klass = Record.record_classes.find { |k| k.type == type }
      arity = klass.instance_method(:initialize).arity - 2

      unless arity == args.size
        raise RecordCreationArityError.new(arity, args.size)
      end

      record = klass.new(self, label, *args)
      records << record
      record.sync!
    end

    def delete_record(rec_label)
      record = records.find { |r| r.label == rec_label }
      return unless record

      File.delete(record.path)
      records.delete(record)
    end

    def record?(label)
      record_labels.include?(label)
    end

    private

    def record_paths
      Dir[File.join(directory, "*.json")]
    end

    def load_records!
      record_paths.map do |path|
        Record.load_record! self, path
      end
    end

    def stringified_users
      config[:users].join(",")
    end

    def rel_path(rel, mkdir: false)
      path = File.join(Config[:mount], "private", stringified_users, rel)

      FileUtils.mkdir_p path if mkdir

      path
    end
  end
end
