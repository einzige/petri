require 'securerandom'

module Petri
  class Element
    attr_reader :net, :data, :guid

    # @param net [Net]
    # @param data [Hash<Symbol>]
    def initialize(net, data = {})
      @net = net
      @data = data.symbolize_keys || {}
      @guid ||= (data[:guid] ||= generate_guid)
    end

    def [](key)
      @data[key]
    end

    def []=(k, v)
      @data[k] = v
    end

    private

    def generate_guid
      SecureRandom.uuid
    end
  end
end
