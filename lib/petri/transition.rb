module Petri
  class Transition < Node

    # @return [String, nil]
    def action
      @data[:action].presence
    end

    def automated?
      @data[:automated].present?
    end

    def inhibitor_places
      ingoing_arcs.select(&:inhibitor?).map(&:from_node)
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

    # @return [Array<Arc>]
    def guard_arcs
      ingoing_arcs.select { |arc| arc.guard.present? }
    end

    def timer_arc
      input_arcs.find { |arc| arc.timer_rule.present? }
    end

    def timer_rule
      timer_arc.try!(:timer_rule)
    end

    def inspect
      "Petri::Transition<#{identifier}>"
    end
  end
end
