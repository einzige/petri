# frozen_string_literal: true
module Petri
  module NetLoader
    class BpfReader
      # Lists of fields to pull per each element type
      ARC_FIELDS = %i[from_guid to_guid type timer_rule guard pin].freeze
      PLACE_FIELDS = %i[guid identifier].freeze
      TRANSITION_FIELDS = %i[guid identifier automated].freeze
      MESSAGE_FIELDS = %i[guid identifier type].freeze
      TASK_FIELDS = %i[guid identifier manual_finish_enabled process_class].freeze

      # @param full_bpf_json_hash [Hash]
      def initialize(full_bpf_json_hash)
        @hash = full_bpf_json_hash
      end

      # @return [Array<Hash>]
      def arcs
        collection_data('arcs', *ARC_FIELDS)
      end

      # @return [Array<Hash>]
      def places
        collection_data('places', *PLACE_FIELDS)
      end

      # @return [Array<Hash>]
      def transitions
        collection_data('transitions', *TRANSITION_FIELDS) do |element_data|
          {automated: to_boolean(element_data['automated'])}
        end
      end

      # @return [Array<Hash>]
      def messages
        collection_data('messages', *MESSAGE_FIELDS) { |element_data| {type: (element_data['sender'] ? :sender : :receiver)} }
      end

      # @return [Array<Hash>]
      def tasks
        collection_data('tasks', *TASK_FIELDS) do |element_data|
          {task_identifier: element_data['identifier'], manual_finish_enabled: to_boolean(element_data['manual_finish_enabled'])}
        end
      end

      private

      # @param key [String] collection name from bpf: places, transitions, tasks, arcs etc
      # @param keys [Array<Symbol>] list of fields to keep in element attributes
      # @yield [Hash] changes collection data per element basis
      # @return [Array<Hash>]
      def collection_data(key, *keys, &block)
        return [] if @hash[key].blank?
        @hash[key].map { |element_data| slice(element_data, *keys, &block) }
      end

      # @param element_data [Hash] single node data, one item from BPF
      # @param keys [Array<Symbol>] a list of keys from data to keep in the node attributes (those you use in the engine)
      # @yield for a data extension
      def slice(element_data, *keys, &block)
        {}.tap do |result|
          keys.each { |key| result[key] = element_data[key.to_s] }

          if block
            extension = yield(element_data)
            result.merge!(extension) if extension
          end
        end
      end

      # @param [Boolean, String, nil]
      # @return [Boolean]
      def to_boolean(value)
        [true, 'yes', 'true', 'on', '1'].include?(value)
      end
    end
  end
end
