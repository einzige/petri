module Petri
  class Message < Transition

    # @return [String, nil]
    def action
      nil
    end

    def automated?
      true
    end

    def input_places
      input_nodes
    end

    def output_places
      output_nodes
    end

    # @return [Array<Place>]
    def places_to_reset
      reset_arcs.map(&:to_node)
    end

    # @return [Array<Arc>]
    def reset_arcs
      net.arcs.select { |arc| arc.from_node == self && arc.reset? }
    end
  end
end
