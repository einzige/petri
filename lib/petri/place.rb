module Petri
  class Place < Node

    def start?
      !!@data[:start]
    end

    def finish?
      !!@data[:finish]
    end

    # @return [Array<Arc>]
    def reset_arcs
      net.arcs.select { |arc| arc.to_node == self && arc.reset? }
    end

    # @return [Array<Transition>]
    def reset_transitions
      reset_arcs.map(&:from_node)
    end

    # For a finish place returns start places with the same identifier.
    # For nets where a finish place may be connected with start places
    # in order to initialize one flow as a result of another.
    # @return [Array<Place>]
    def links
      if finish?
        @net.places.select { |place| place.start? && place.identifier == identifier }
      else
        []
      end
    end

    def inspect
      "Petri::Place<#{identifier}>"
    end
  end
end
