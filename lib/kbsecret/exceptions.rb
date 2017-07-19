# frozen_string_literal: true

module KBSecret
  # A namespace for all exceptions used by {KBSecret}.
  module Exceptions
    # A generic error in {KBSecret}.
    class KBSecretError < RuntimeError
    end

    # Raised during record loading if a particular file can't be loaded
    class RecordLoadError < KBSecretError
      def initialize(path)
        base = File.basename(path)
        super "Failed to load record in file: '#{base}'"
      end
    end

    # Raised during record creation if an unknown record type is requested.
    class RecordTypeUnknownError < KBSecretError
      def initialize(type)
        super "Unknown record type: '#{type}'"
      end
    end

    # Raised during record creation if too many/few arguments are given.
    class RecordCreationArityError < KBSecretError
      def initialize(exp, act)
        super "Needed #{exp} arguments for this record, got #{act}"
      end
    end

    # Raised during session load if an error occurs.
    class SessionLoadError < KBSecretError
      def initialize(msg)
        super "Session loading failure: #{msg}"
      end
    end

    # Raised during session lookup if an unknown session is requested.
    class SessionUnknownError < KBSecretError
      def initialize(sess)
        super "Unknown session: '#{sess}'"
      end
    end

    # Raised during generator lookup if an unknown profile is requested.
    class GeneratorUnknownError < KBSecretError
      def initialize(gen)
        super "Unknown generator profile: '#{gen}'"
      end
    end

    # Raised during generator creation if an unknown generator format is requested.
    class GeneratorFormatError < KBSecretError
      def initialize(fmt)
        super "Unknown generator format: '#{fmt}'"
      end
    end

    # Raised during generator creation if a non-positive generator length is requested.
    class GeneratorLengthError < KBSecretError
      def initialize(length)
        super "Bad secret generator length (#{length}, must be positive)"
      end
    end
  end
end
