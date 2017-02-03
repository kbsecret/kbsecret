require "json"

module KBSecret
  module Record
    # @abstract
    class Abstract
      attr_accessor :session
      attr_reader :timestamp
      attr_reader :label
      attr_reader :type
      attr_reader :data

      def self.type
        name.split("::").last.downcase
      end

      def self.load!(session, hsh)
        instance = allocate
        instance.session = session
        instance.initialize_from_hash(hsh)

        instance
      end

      def initialize(session, label)
        @session = session
        @timestamp = Time.now.to_i
        @label = label
        @type = self.class.type
        @data = {}
      end

      def initialize_from_hash(hsh)
        @timestamp = hsh[:timestamp]
        @label = hsh[:label]
        @type = hsh[:type]
        @data = hsh[:data]
      end

      def path
        File.join(session.directory, "#{label}.json")
      end

      def to_h
        {
          timestamp: timestamp,
          label: label,
          type: type,
          data: data,
        }
      end

      def sync!
        # bump the timestamp every time we sync
        @timestamp = Time.now.to_i

        File.write(path, JSON.pretty_generate(to_h))
      end
    end
  end
end
