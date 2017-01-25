# frozen_string_literal: true
module Petri
  class Message < Transition
    element_attribute :type, :message_identifier

    # @param net [Net]
    # @param data [Hash<Symbol>]
    def initialize(net, data = {})
      super
      @data[:identifier] ||= generate_identifier
    end

    def receiver?
      type == :receiver
    end

    def sender?
      type == :sender
    end

    def automated?
      true
    end

    def inspect
      "Petri::Message<#{identifier}>"
    end

    private

    def generate_identifier
      case type&.to_sym
      when :sender then "SEND '#{message_identifier}'"
      when :receiver then "RECEIVE '#{message_identifier}'"
      else
        raise ArgumentError, "No such message type '#{type.inspect}'"
      end
    end
  end
end
