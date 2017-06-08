# frozen_string_literal: true

require "fileutils"

module KBSecret
  # Represents a session of N keybase users with collective read/write
  # access to a collection of records.
  class Session
    # @return [Symbol] the session's label
    attr_reader :label

    # @return [Hash] the session-specific configuration, from
    #  {Config::CONFIG_FILE}
    attr_reader :config

    # @return [String] the fully-qualified path of the session
    attr_reader :directory

    # @param label [String, Symbol] the label of the session to initialize
    # @note This does not *create* a new session, but loads one already
    #  specified in {Config::CONFIG_FILE}. To *create* a new session,
    #  see {Config.configure_session}.
    def initialize(label: :default)
      @label     = label.to_sym
      @config    = Config.session(@label)

      @directory = rel_path config[:root], mkdir: true
      @records   = load_records!
    end

    # @param type [String, Symbol] the type of the records to return (or `nil` for all)
    # @return [Array<Record::Abstract>] records associated with the session
    def records(type = nil)
      if type
        @records.select { |r| r.type == type.to_sym }
      else
        @records
      end
    end

    # @return [Array<Symbol>] the labels of all records known to the session
    # @example
    #  session.record_labels # => [:website1, :apikey1, :website2]
    def record_labels
      records.map(&:label)
    end

    # Add a record to the session.
    # @param type [String, Symbol] the type of record (see {Record.record_types})
    # @param label [Symbol] the new record's label
    # @param args [Array<String>] the record-type specific arguments
    # @return [void]
    # @raise RecordCreationArityError if the number of specified record
    #  arguments does not match the record type's constructor
    def add_record(type, label, *args)
      klass = Record.class_for(type.to_sym)
      arity = klass.instance_method(:initialize).arity - 2

      raise RecordCreationArityError.new(arity, args.size) unless arity == args.size

      record = klass.new(self, label, *args)
      records << record
      record.sync!
    end

    # Delete a record from the session, if it exists. Does nothing if
    # no such record can be found.
    # @param rec_label [Symbol] the label of the record to delete
    # @return [void]
    def delete_record(rec_label)
      record = records.find { |r| r.label == rec_label }
      return unless record

      File.delete(record.path)
      records.delete(record)
    end

    # @return [Boolean] whether or not the session contains a record with the
    #  given label
    def record?(label)
      record_labels.include?(label)
    end

    # Delete the entire session.
    # @return [void]
    # @note Use this with caution, as *all* files under the session directory
    #   will be deleted. Furthermore, the session directory itself will
    #   be deleted, and this object will become garbage.
    def unlink!
      FileUtils.rm_rf(directory)
    end

    # @return [Array<String>] the fully qualified paths of all records in the session
    # @api private
    def record_paths
      Dir[File.join(directory, "*.json")]
    end

    # Load all records associated with the session.
    # @return [Array<Record::Abstract>] all records in the session
    # @api private
    def load_records!
      record_paths.map do |path|
        Record.load_record! self, path
      end
    end

    # @param rel [String, Symbol] the "root" of the session
    # @param mkdir [Boolean] whether or not to make the session directory
    # @return [String] the fully qualified path to the session
    # @api private
    def rel_path(rel, mkdir: false)
      # /keybase/private/[username]/kbsecret/[session]
      path = File.join(Config[:mount], "private",
                       Keybase::U[config[:users]],
                       Config[:session_root],
                       rel)

      FileUtils.mkdir_p path if mkdir

      path
    end
  end
end
