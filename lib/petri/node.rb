# frozen_string_literal: true
module Petri
  class Node < Element
    attr_reader :guid
    element_attribute :identifier

    # @param net [Net]
    # @param data [Hash<Symbol>]
    def initialize(net, **data)
      super
      @guid ||= (data[:guid] ||= generate_guid)
    end

    # @return [Array<Arc>]
    def input_arcs
      net.arcs.select { |arc| arc.to_node == self && arc.regular? }
    end

    # @return [Array<Node>]
    def input_nodes
      input_arcs.map(&:from_node)
    end

    # @return [Array<Arc>]
    def output_arcs
      net.arcs.select { |arc| arc.from_node == self && arc.regular? }
    end

    # @return [Array<Node>]
    def output_nodes
      output_arcs.map(&:to_node)
    end

    # @return [Array<Arc>]
    def ingoing_arcs
      net.arcs.select { |arc| arc.to_node == self }
    end

    # @return [Array<Arc>]
    def outgoing_arcs
      net.arcs.select { |arc| arc.from_node == self }
    end

    private

    def generate_guid
      SecureRandom.uuid
    end
  end
end
