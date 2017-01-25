# frozen_string_literal: true
require 'securerandom'

module Petri
  class Element
    attr_reader :net, :data

    # @param attrs [Array<Symbol>] a list of attributes to fetch from element @data
    def self.element_attribute(*attrs)
      attrs.each do |attr|
        define_method(attr) { @data[attr] }
      end
    end

    # @param net [Net]
    # @param data [Hash<Symbol>]
    def initialize(net, data = {})
      @net = net
      @data = data.symbolize_keys || {}
      @data[:type] = @data[:type].to_sym if @data[:type].is_a?(String)
    end

    # @param key [Symbol]
    def [](key)
      @data[key.to_sym]
    end

    # @param key [Symbol]
    # @param value
    def []=(key, value)
      @data[key.to_sym] = value
    end
  end
end
