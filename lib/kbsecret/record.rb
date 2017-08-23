# frozen_string_literal: true

require "json"

# we have to require abstract first because ruby's module resolution is bad
require_relative "record/abstract"

# we load custom types first, to ensure that the builtin types take precedence
Dir[File.join(KBSecret::Config::CUSTOM_TYPES_DIR, "*.rb")].each { |t| require_relative t }
Dir[File.join(__dir__, "record/*.rb")].each { |t| require_relative t }

module KBSecret
  # The namespace for {KBSecret} record types.
  module Record
    # @return [Array<Class>] the class objects of all non-abstract record types
    def self.record_classes
      klasses = constants.map(&Record.method(:const_get)).grep(Class)
      klasses.delete(Record::Abstract)
      klasses
    end

    # @return [Array<Symbol>] the types of all records
    def self.record_types
      record_classes.map(&:type)
    end

    # @param type [String, Symbol] the record type
    # @return [Class] the record class corresponding to the given type
    # @raise [Exceptions::RecordTypeUnknownError] if the requested type is unknown
    def self.class_for(type)
      klass = record_classes.find { |c| c.type == type.to_sym }
      raise Exceptions::RecordTypeUnknownError, type unless klass
      klass
    end

    # @param type [String, Symbol] the record type
    # @return [Boolean] whether a record class exists of the given type
    def self.type?(type)
      return false unless type
      record_types.include?(type.to_sym)
    end

    # Load a record by path into the given session.
    # @param session [Session] the session to load into
    # @param path [String] the fully-qualified record path
    # @return [Record::AbstractRecord] the loaded record
    # @raise [Exceptions::RecordLoadError] if an error occurs during record loading
    # @api private
    def self.load_record!(session, path)
      hsh   = JSON.parse(File.read(path), symbolize_names: true)
      klass = class_for hsh[:type]
      klass&.load!(session, hsh)
    rescue
      raise Exceptions::RecordLoadError, path
    end
  end
end
