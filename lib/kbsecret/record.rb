require "json"

require_relative "record/abstract"
require_relative "record/login"
require_relative "record/environment"
require_relative "record/unstructured"

module KBSecret
  module Record
    def self.record_classes
      klasses = constants.map(&Record.method(:const_get)).grep(Class)
      klasses.delete(Record::Abstract)
      klasses
    end

    def self.record_types
      record_classes.map(&:type)
    end

    def self.type?(type)
      record_types.include?(type)
    end

    def self.load_record!(session, path)
      hsh = JSON.parse(File.read(path), symbolize_names: true)
      klass = record_classes.find { |c| c.type == hsh[:type] }
      klass.load!(session, hsh)
    end
  end
end
