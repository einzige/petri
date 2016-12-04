module Petri
  class Net
    include NetLoader

    attr_reader :places, :transitions, :arcs

    def initialize
      @transitions = []
      @places = []
      @arcs = []
      @data = {}
    end

    # @return [Array<Transition>]
    def automated_transitions
      transitions.select(&:automated?)
    end

    # @return [Array<Message>]
    def messages
      transitions.select { |transition| transition.is_a?(Petri::Message) }
    end

    # @return [Place]
    def start_place
      start_places = @places.select(&:start?).select do |place|
        place.identifier.blank? ||
          places_by_identifier(place.identifier).select(&:finish?).empty?
      end

      raise ArgumentError, 'There are more than one start places' if start_places.many?
      raise ArgumentError, 'There is no start place' if start_places.empty?

      start_places.first
    end

    # @param identifier [String]
    # @return [Place, nil]
    def place_by_identifier(identifier)
      identifier = identifier.to_s
      @places.each { |node| return node if node.identifier == identifier }
      nil
    end

    # @param identifier [String]
    # @return [Transition, nil]
    def transition_by_identifier(identifier, automated: nil)
      identifier = identifier.to_s
      transitions = @transitions.select do |transition|
        if automated
          transition.automated?
        elsif automated == false
          !transition.automated?
        else
          true
        end
      end

      transitions.each { |node| return node if node.identifier == identifier }

      nil
    end

    # @param identifier [String]
    # @return [Array<Transition>]
    def transitions_by_identifier(identifier)
      @transitions.select { |node| node.identifier == identifier }
    end

    # @param guard [String]
    # @return [Arc, nil]
    def arc_by_guard(guard)
      return if guard.blank?

      guard = Arc.normalize_guard(guard)
      @arcs.each { |arc| return arc if arc.normalized_guard == guard }
      nil
    end

    # @param identifier [String]
    # @return [Node, nil]
    def node_by_identifier(identifier)
      place_by_identifier(identifier) || transition_by_identifier(identifier)
    end

    def [](key)
      @data[key]
    end

    def []=(k, v)
      @data[k] = v
    end

    def inspect
      "Petri::Net#{hash}"
    end

    protected

    # @param guid [String]
    # @return [Node, nil]
    def node_by_guid(guid)
      @places.each { |node| return node if node.guid == guid }
      @transitions.each { |node| return node if node.guid == guid }
      nil
    end

    # @param identifier [String]
    # @return [Array<Place>]
    def places_by_identifier(identifier)
      identifier = identifier.to_s
      @places.select { |node| node.identifier == identifier }
    end
  end
end
