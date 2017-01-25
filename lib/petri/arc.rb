# frozen_string_literal: true
module Petri
  class Arc < Element
    element_attribute :pin, :timer_rule, :guard, :type
    attr_reader :from_node, :to_node

    # @param net [Petri::Net]
    # @param from_node [Node]
    # @param to_node [Node]
    # @param data [Hash<Symbol>] :pin, :timer_rule, :guard
    def initialize(net, from_node:, to_node:, **data)
      super(net, data)
      @from_node = from_node
      @to_node = to_node
    end

    def inhibitor?
      type == :inhibitor
    end

    def regular?
      type == :regular
    end

    def reset?
      type == :reset
    end

    # @return [String, nil]
    def normalized_guard
      @normalize_guard ||= self.class.normalize_guard(guard)
    end

    # Returns guard without extra spaces
    # @param guard [String, nil]
    def self.normalize_guard(guard)
      return unless guard
      guard.to_s.gsub(/\s+/, ' ').strip
    end
  end
end
