# frozen_string_literal: true
module Petri
  class Place < Node
    element_attribute :persisted

    # @param net [Net]
    # @param data [Hash<Symbol>]
    # @option data persisted [Boolean] some generated places have no bindings, at the same time some of them (depends on the net structure) are required to be persisted
    def initialize(net, persisted: false, **data)
      super(net, persisted: persisted, **data)
    end

    def persisted?
      persisted
    end

    # @return [Array<Arc>]
    def reset_arcs
      net.arcs.select { |arc| arc.to_node == self && arc.reset? }
    end

    # @return [String]
    def inspect
      "Petri::Place<#{identifier}>"
    end
  end
end
