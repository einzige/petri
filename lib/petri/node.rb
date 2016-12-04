module Petri
  class Node < Element

    # @return [String, nil]
    def identifier
      @data[:identifier]
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
    def outgoing_arcs
      net.arcs.select { |arc| arc.from_node == self }
    end

    # @return [Array<Arc>]
    def ingoing_arcs
      net.arcs.select { |arc| arc.to_node == self }
    end
  end
end
