# frozen_string_literal: true

require "json"

module KBSecret
  module Record
    # Represents an abstract kbsecret record that can be subclassed to produce
    # more useful records.
    # @abstract
    class Abstract
      # @return [Session] the session associated with the record
      attr_accessor :session

      # @return [Integer] the UNIX timestamp marking the record's last modification
      attr_reader :timestamp

      # @return [String] the record's label
      attr_reader :label

      # @return [Symbol] the record's type
      attr_reader :type

      # @return [Hash] the record's data
      attr_reader :data

      # @return [String] the fully qualified path to the record in KBFS
      attr_reader :path

      class << self
        # Add a field to the record's data.
        # @param field [Symbol] the new field's name
        # @return [void]
        def data_field(field)
          @fields ||= []
          @fields << field

          gen_methods field
        end

        # Generate the methods used to access a given field.
        # @param field [Symbol] the new field's name
        # @return [void]
        def gen_methods(field)
          class_eval %[
            def #{field}
              @data[self.class.type.to_sym]["#{field}".to_sym]
            end

            def #{field}=(val)
              @data[self.class.type.to_sym]["#{field}".to_sym] = val
              @timestamp = Time.now.to_i
              sync!
            end
          ]
        end

        # @return [Array<Symbol>] all data fields for the record class
        def data_fields
          @fields
        end

        # @return [Symbol] the record's type
        # @example
        #  KBSecret::Record::Abstract.type # => :abstract
        def type
          name.split("::")                       # ["Foo", "BarBaz"]
              .last                              # "BarBaz"
              .gsub(/([^A-Z])([A-Z]+)/, '\1_\2') # "Bar_Baz"
              .downcase                          # "bar_baz"
              .to_sym                            # :bar_baz
        end

        # Load the given hash-representation into a record.
        # @param session [Session] the session to associate with
        # @param hsh [Hash] the record's hash-representation
        # @return [Record::AbstractRecord] the created record
        # @api private
        def load!(session, hsh)
          instance         = allocate
          instance.session = session
          instance.initialize_from_hash(hsh)

          instance
        end
      end

      # Create a brand new record, associated with a session.
      # @param session [Session] the session to associate with
      # @param label [String, Symbol] the new record's label
      # @note Creation does *not* sync the new record; see {#sync!} for that.
      def initialize(session, label)
        @session   = session
        @timestamp = Time.now.to_i
        @label     = label.to_s
        @type      = self.class.type
        @data      = {}
        @path      = File.join(session.directory, "#{label}.json")
      end

      # Fill in instance fields from a record's hash-representation.
      # @param hsh [Hash] the record's hash-representation.
      # @return [void]
      # @api private
      def initialize_from_hash(hsh)
        @timestamp = hsh[:timestamp]
        @label     = hsh[:label]
        @type      = hsh[:type].to_sym
        @data      = hsh[:data]
        @path      = File.join(session.directory, "#{label}.json")
      end

      # Create a hash-representation of the current record.
      # @return [Hash] the hash-representation
      def to_h
        {
          timestamp: timestamp,
          label: label,
          type: type,
          data: data,
        }
      end

      # Write the record's in-memory state to disk.
      # @note Every sync updates the record's timestamp.
      # @return [void]
      def sync!
        # bump the timestamp every time we sync
        @timestamp = Time.now.to_i

        File.write(path, JSON.pretty_generate(to_h))
      end
    end
  end
end
