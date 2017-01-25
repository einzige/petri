# frozen_string_literal: true
module Petri
  module NetLoader
    include Arcs
    include Tasks

    # @param guid [String]
    # @param identifier [String]
    # @param persisted [Boolean]
    # @return [Place]
    def add_place(**opts)
      Place.new(self, **opts).tap { |element| @places << element }
    end

    # @param guid [String]
    # @param identifier [String]
    # @param automated [Boolean]
    # @return [Transition]
    def add_transition(**opts)
      Transition.new(self, **opts).tap { |element| @transitions << element }
    end

    # @param guid [String]
    # @param identifier [String]
    # @param type [Symbol] sender or receiver
    # @return [Message]
    def add_message(identifier:, type:, **opts)
      Message.new(self, opts.merge(message_identifier: identifier, type: type)).tap { |element| @transitions << element }
    end

    # @param extendee [Class] class to extend
    def self.included(extendee)
      extendee.extend(ClassMethods)
    end

    module ClassMethods
      # @param path [String]
      # @return [Net]
      def from_file(path)
        from_stream(File.new(path))
      end

      # @param hash [Hash<String>]
      # @return [Net]
      # rubocop:disable Metrics/AbcSize
      def from_hash(hash)
        load_flow(hash.slice('hash', 'identifier', 'tasks_process_class')) do |net|
          parser = BpfReader.new(hash)
          parser.places.each { |element_data| net.add_place(element_data) }
          parser.transitions.each { |element_data| net.add_transition(element_data) }
          parser.messages.each { |element_data| net.add_message(element_data) }
          parser.tasks.each { |element_data| net.add_task(element_data) }
          parser.arcs.each { |element_data| net.add_arc(element_data) }
        end
      end

      # @param io [IO]
      # @return [Net]
      def from_stream(io)
        from_string(io.read)
      end

      # @param str [String]
      # @return [Net]
      def from_string(str)
        from_hash(JSON.parse(str))
      end
    end
  end
end
