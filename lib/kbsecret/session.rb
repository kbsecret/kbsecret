# frozen_string_literal: true

require "fileutils"

module KBSecret
  # Represents a session of Keybase users with collective read and/or write
  # access to a collection of records.
  class Session
    # @return [Symbol] the session's label
    attr_reader :label

    # @return [Hash] the session-specific configuration, from
    #  {Config::CONFIG_FILE}
    attr_reader :config

    # @return [String] the fully-qualified path of the session
    attr_reader :path

    # @param label [String, Symbol] the label of the session to initialize
    # @return [Session]
    # @see #initialize
    def self.[](label)
      new(label: label)
    end

    # @param label [String, Symbol] the label of the session to initialize
    # @raise [Exceptions::SessionLoadError] if the session has no users or any invalid Keybase users
    # @note This does not *create* a new session, but loads one already
    #  specified in {Config::CONFIG_FILE}. To *create* a new session,
    #  see {Config.configure_session}.
    def initialize(label: :default)
      @label     = label.to_sym
      @config    = Config.session(@label)

      # team sessions don't have explicit users
      unless @config[:team]
        raise Exceptions::SessionLoadError, "no users in session" if @config[:users].empty?
      end

      @path    = rel_path mkdir: true
      @records = load_records!
    end

    # @param label [String, Symbol] the label of the record to fetch
    # @return [Record::Abstract, nil] the record with the requested label, if extant
    def [](label)
      @records.find { |r| r.label == label.to_s }
    end

    # All records (of a given type) in the session.
    # @param type [String, Symbol] the type of the records to return (or `nil` for all)
    # @return [Array<Record::Abstract>] records associated with the session
    def records(type = nil)
      if type
        @records.select { |r| r.type == type.to_sym }
      else
        @records
      end
    end

    # @return [Array<String>] the labels of all records known to the session
    # @example
    #  session.record_labels # => ["website1", "apikey1", "website2"]
    def record_labels
      records.map(&:label)
    end

    # Add a record to the session.
    # @param type [String, Symbol] the type of record (see {Record.record_types})
    # @param label [String, Symbol] the new record's label
    # @param args [Array<String>] the record-type specific arguments
    # @param overwrite [Boolean] whether or not to overwrite an existing record if necessary
    # @return [void]
    # @raise [Exceptions::RecordTypeUnknownError] if the requested type does not exist
    #  in {Record.record_types}
    # @raise [Exceptions::RecordCreationArityError] if the number of specified record
    #  arguments does not match the record type's constructor
    # @raise [Exceptions::RecordOverwriteError] if the record addition would cause an
    #  unchecked overwrite
    # @example
    #  session.add_record :login, "gmail", "bob@gmail.com", "hunter2"
    def add_record(type, label, *args, overwrite: false)
      klass = Record.class_for(type.to_sym)
      arity = klass.external_fields.length

      raise Exceptions::RecordCreationArityError.new(arity, args.size) unless arity == args.size

      if record? label
        raise Exceptions::RecordOverwriteError.new(self, label) unless overwrite
        delete_record label
      end

      body   = klass.external_fields.zip(args).to_h
      record = klass.new(self, label.to_s, **body)

      records << record
      record.sync!
    end

    # Import an existing record from another session.
    # @param record [Record::Abstract] the record to import
    # @param overwrite [Boolean] whether or not to overwrite an existing record if necessary
    # @return [void]
    # @raise [Exceptions::SessionImportError] if the record's source session is our session
    # @raise [Exceptions::RecordOverwriteError] if record import would cause an unchecked overwrite
    # @example
    #  session.import_record other_session["gmail"], overwrite: true
    def import_record(record, overwrite: false)
      raise Exceptions::SessionImportError, self if self == record.session

      if record? record.label
        raise Exceptions::RecordOverwriteError.new(self, record.label) unless overwrite
        delete_record record.label
      end

      klass = record.class
      imported_record = klass.load!(self, record.to_h)
      records << imported_record
      imported_record.sync!
    end

    # Delete a record from the session, if it exists. Does nothing if
    # no such record can be found.
    # @param label [String, Symbol] the label of the record to delete
    # @return [void]
    # @example
    #  session.delete_record "gmail"
    def delete_record(label)
      record = records.find { |r| r.label == label.to_s }
      return unless record

      File.delete(record.path)
      records.delete(record)
    end

    # @param label [String, Symbol] the label to test for
    # @return [Boolean] whether or not the session contains a record with the
    #  given label
    def record?(label)
      record_labels.include?(label.to_s)
    end

    # Delete the entire session.
    # @return [void]
    # @note Use this with caution, as *all* files under the session path
    #   will be deleted. Furthermore, the session path itself will
    #   be deleted, and this object will become garbage.
    def unlink!
      FileUtils.rm_rf(path)
    end

    # @return [Array<String>] the fully qualified paths of all records in the session
    def record_paths
      Dir[File.join(path, "*.json")]
    end

    # Compare two sessions for equality.
    # @param other [Session] the other object to compare against
    # @return [Boolean] whether or not the two sessions are equal
    # @note The equality of two sessions is determined *solely* by them having the same
    #  session directory, *not* by having the same label *or* the same in-memory state.
    def ==(other)
      other.class == self.class && other.path == path
    end

    # Load all records associated with the session.
    # @return [Array<Record::Abstract>] all records in the session
    # @api private
    def load_records!
      record_paths.map do |path|
        Record.load_record! self, path
      end
    end

    # @param mkdir [Boolean] whether or not to make the session path
    # @return [String] the fully qualified path to the session
    # @api private
    def rel_path(mkdir: false)
      path = if @config[:team]
               File.join(Keybase::Local::Config::KBFS_MOUNT, "team", @config[:team], "kbsecret",
                         @config[:root])
             else
               # /keybase/private/[u1,u2,...,uN]/kbsecret/[session]
               File.join(Keybase::Local::Config::KBFS_MOUNT, "private",
                         Keybase::Core::U[@config[:users]], "kbsecret", @config[:root])
             end

      FileUtils.mkdir_p path if mkdir

      path
    end
  end
end
