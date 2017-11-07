# frozen_string_literal: true

module KBSecret
  # A namespace for all exceptions defined by {KBSecret}.
  module Exceptions
    # A generic error in {KBSecret}.
    class KBSecretError < RuntimeError
    end

    # Raised during record loading if a particular file can't be loaded
    class RecordLoadError < KBSecretError
      # @param path [String] the path to the record
      def initialize(path)
        base = File.basename(path)
        super "Failed to load record in file: '#{base}'"
      end
    end

    # Raised during record creation if an unknown record type is requested.
    class RecordTypeUnknownError < KBSecretError
      # @param type [String, Symbol] the record type
      def initialize(type)
        super "Unknown record type: '#{type}'"
      end
    end

    # Raised during record creation if too many/few arguments are given.
    class RecordCreationArityError < KBSecretError
      # @param exp [Integer] the number of expected arguments
      # @param act [Integer] the number of actual arguments
      def initialize(exp, act)
        super "Needed #{exp} arguments for this record, got #{act}"
      end
    end

    # Raised when record creation or import would cause an unintended overwrite.
    class RecordOverwriteError < KBSecretError
      # @param session [Session] the session being modified
      # @param label [String] the label being overwritten in the session
      def initialize(session, label)
        super "Record '#{label}' already exists in '#{session.label}'"
      end
    end

    # Raised during session load if an error occurs.
    class SessionLoadError < KBSecretError
      # @param msg [String] the error message
      def initialize(msg)
        super "Session loading failure: #{msg}"
      end
    end

    # Raised during session lookup if an unknown session is requested.
    class SessionUnknownError < KBSecretError
      # @param sess [String, Symbol] the label of the session
      def initialize(sess)
        super "Unknown session: '#{sess}'"
      end
    end

    # Raised during record import if the source is the same as the destination.
    class SessionImportError < KBSecretError
      # @param session [Session] the session being imported into
      def initialize(session)
        super "Session '#{session.label}' cannot import records from itself"
      end
    end

    # Raised during generator lookup if an unknown profile is requested.
    class GeneratorUnknownError < KBSecretError
      # @param gen [String, Symbol] the label of the generator
      def initialize(gen)
        super "Unknown generator profile: '#{gen}'"
      end
    end

    # Raised during generator creation if an unknown generator format is requested.
    class GeneratorFormatError < KBSecretError
      # @param fmt [String, Symbol] the format of the generator
      def initialize(fmt)
        super "Unknown generator format: '#{fmt}'"
      end
    end

    # Raised during generator creation if a non-positive generator length is requested.
    class GeneratorLengthError < KBSecretError
      # @param length [Integer] the length of the generator
      def initialize(length)
        super "Bad secret generator length (#{length}, must be positive)"
      end
    end
  end
end
