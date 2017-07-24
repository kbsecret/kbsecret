# frozen_string_literal: true

module KBSecret
  module Record
    # Represents a record containing a 'to do' item and its status.
    #
    # Apart from the text of the item itself, each record contains three
    # relevant fields: the item's status, a start time, and a stop time.
    #
    # The status is one of `"started"`, `"suspended"`, or `"complete"`, each
    # of which should be self-explanatory.
    #
    # The start time is the date and time at which the item was started via
    # {#start!}.
    #
    # The stop time is the date and time at which the item was *either*
    # last suspended via {#suspend!} *or* finished via {#complete!}.
    class Todo < Abstract
      # @!attribute todo
      #  @return [String] the todo message
      # @!attribute status
      #  @return [String] the todo record's status (one of "started", "suspended", or "complete")
      #  @note This is an internal field.
      # @!attribute start
      #  @return [String] a string representation of the record's (last) start time
      #  @note This is an internal field.
      # @!attribute stop
      #  @return [String] a string representation of the record's (last) stop time
      #  @note This is an internal field.
      data_field :todo, sensitive: false
      data_field :status, sensitive: false, internal: true
      data_field :start, sensitive: false, internal: true
      data_field :stop, sensitive: false, internal: true

      # @return [void]
      # @see Abstract#populate_internal_fields
      def populate_internal_fields
        defer_sync implicit: false do
          self.status = "suspended"
          self.start = nil
          self.stop = nil
        end
      end

      # @return [Boolean] whether or not the item is marked as started
      def started?
        status == "started"
      end

      # @return [Boolean] whether or not the item is marked as suspended
      def suspended?
        status == "suspended"
      end

      # @return [Boolean] whether or not the item is marked as completed
      def completed?
        !(started? || suspended?)
      end

      # Start the to do item.
      # @return [void]
      # @note Does nothing if the item is already started.
      def start!
        return if started?

        self.status = "started"
        self.start  = Time.now.to_s
      end

      # Suspend the to do item.
      # @return [void]
      # @note Does nothing if the item is already suspended.
      def suspend!
        return if suspended?
        self.status = "suspended"
        self.stop   = Time.now.to_s
      end

      # Complete the to do item.
      # @return [void]
      # @note Does nothing if the item is already completed.
      def complete!
        return if completed?
        self.status = "complete"
        self.stop   = Time.now.to_s
      end
    end
  end
end
