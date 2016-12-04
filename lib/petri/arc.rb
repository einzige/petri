module Petri
  class Arc < Element
    attr_reader :from_node, :to_node, :type

    def initialize(net, from: nil, to: nil, type: nil, guid: nil, production_rule: nil, guard: nil)
      super(net, {guid: guid, production_rule: production_rule, guard: guard})
      @from_node = from
      @to_node = to
      @type = type.try(:to_sym) || :regular
    end

    def reset?
      @type == :reset
    end

    def regular?
      @type == :regular
    end

    def inhibitor?
      @type == :inhibitor
    end

    def production_rule
      data[:production_rule]
    end

    def guard
      data[:guard]
    end

    def normalized_guard
      self.class.normalize_guard(guard)
    end

    def self.normalize_guard(guard)
      return unless guard
      guard.to_s.gsub(/\s+/, ' ').strip
    end
  end
end
