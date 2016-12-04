module Petri
  class Token
    attr_reader :place, :source_transition, :data

    # @param place [Place]
    # @param source_transition [Transition, nil]
    def initialize(place, source_transition = nil)
      @place = place
      @source_transition = source_transition
      @data = {}
    end

    # @return [String, nil]
    def production_rule
      source_arc && source_arc.production_rule
    end

    # @return [Arc, nil]
    def source_arc
      if source_transition
        place.input_arcs.find { |arc| arc.from_node == source_transition }
      end
    end

    def []=(k, v)
      @data[k] = v
    end

    def [](k)
      @data[k]
    end
  end
end
