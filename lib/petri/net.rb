# frozen_string_literal: true
module Petri
  class Net
    include Messages
    include NetLoader

    attr_reader :places, :transitions, :arcs

    # Opens block to load elements into the instance safely
    # @param data [Hash] any workflow related data, examples: hash, identifier, version, editor version etc
    # @return [Net]
    def self.load_flow(data)
      new.load_flow(data) { |net| yield(net) }
    end

    def initialize
      @data = {}
      @arcs = []
      @places = []
      @tasks = []
      @transitions = []
    end

    # @param data [Hash] any workflow related data, examples: hash, identifier, version, editor version etc
    # @return [self]
    def load_flow(data)
      @data = data.symbolize_keys
      @cache = {}
      @loaded = false
      yield(self)
      @loaded = true
      self
    end

    # @return [Array<Transition>]
    def automated_transitions
      cache(:automated_transitions) { transitions.select(&:automated?) }
    end

    # @return [Array<Transition>]
    def manual_transitions
      cache(:manual_transitions) { transitions.select(&:manual?) }
    end

    # @param identifier [String]
    # @return [Array<Transition>]
    def transitions_by_identifier(identifier)
      transitions.select(&by_identifier(identifier))
    end

    # @param identifier [String]
    # @param automated [Boolean, nil] nil if doesn't matter
    # @return [Transition, nil]
    def transition_by_identifier(identifier, automated: nil)
      case automated
      when nil
        transitions
      when true
        automated_transitions
      when false
        manual_transitions
      end.find(&by_identifier(identifier))
    end

    # @param identifier [String]
    # @return [Place, nil]
    def place_by_identifier(identifier)
      places.find(&by_identifier(identifier))
    end

    # @param guid [String]
    # @return [Node, nil]
    def node_by_guid(guid)
      by_guid = proc { |node| return node if node.guid == guid }
      @places.each(&by_guid)
      @transitions.each(&by_guid)
      @tasks.each(&by_guid)
      nil
    end

    # Returns default name of the class to handle tasks behavior
    # @return [String]
    def tasks_process_class
      self[:tasks_process_class] || 'TasksProcess'
    end

    # @param val [String]
    def tasks_process_class=(val)
      self[:tasks_process_class] = val
    end

    # @param key [Symbol]
    # @return
    def [](key)
      @data[key.to_sym]
    end

    # @param key [Symbol]
    # @param value
    # @return value
    def []=(key, value)
      @data[key.to_sym] = value
    end

    # @return [String]
    def inspect
      "Petri::Net#{hash}"
    end

    private

    # @param identifier [String]
    # @return [Proc]
    def by_identifier(identifier)
      identifier = identifier.to_s
      ->(node) { node.identifier == identifier }
    end

    # Returns value from cache only if the net is fully loaded otherwise performs block calculations
    def cache(key)
      if @loaded
        _cache[key.to_sym] ||= yield
      else
        yield
      end
    end

    # @return [Hash]
    def _cache
      @cache ||= {}
    end
  end
end
