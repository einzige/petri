# frozen_string_literal: true
module Petri
  class Transition < Node
    element_attribute :automated

    alias automated? automated
    alias input_places input_nodes
    alias output_places output_nodes

    def manual?
      !automated?
    end

    # @return [Array<Place>]
    def inhibitor_places
      ingoing_arcs.select(&:inhibitor?).map(&:from_node)
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

    # @return [Arc, nil]
    def timer_arc
      input_arcs.find { |arc| arc.timer_rule.present? }
    end

    # @return [String, nil]
    # rubocop:disable Rails/Delegate
    def timer_rule
      timer_arc&.timer_rule
    end

    # @return [String]
    def inspect
      "Petri::Transition<#{identifier}>"
    end
  end
end
