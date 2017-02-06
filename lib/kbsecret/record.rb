require "json"

require_relative "record/abstract"
require_relative "record/login"
require_relative "record/environment"
require_relative "record/unstructured"

module KBSecret
  # The namespace for kbsecret records types.
  module Record
    # @return [Array<Class>] the class objects of all non-abstract record types
    def self.record_classes
      klasses = constants.map(&Record.method(:const_get)).grep(Class)
      klasses.delete(Record::Abstract)
      klasses
    end

    # @return [Array<String>] the types of all records
    def self.record_types
      record_classes.map(&:type)
    end

    # @param type [String] the record type
    # @return [Class, nil] the record class corresponding to the given type
    def self.class_for(type)
      record_classes.find { |c| c.type == type }
    end

    # @param type [String] the record type
    # @return [Boolean] whether a record class exists of the given type
    def self.type?(type)
      record_types.include?(type)
    end

    # Load a record by path into the given session.
    # @param session [Session] the session to load into
    # @param path [String] the fully-qualified record path
    # @return [Record::AbstractRecord] the loaded record
    # @api private
    def self.load_record!(session, path)
      hsh = JSON.parse(File.read(path), symbolize_names: true)
      klass = record_classes.find { |c| c.type == hsh[:type] }
      klass.load!(session, hsh)
    end
  end
end
