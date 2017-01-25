# frozen_string_literal: true
module Petri
  class Net
    module Messages
      # Messages are automated transitions to support interprocess communication
      # @return [Array<Message>]
      def messages
        cache(:messages) { transitions.grep(Petri::Message) }
      end

      # Message senders are automated transitions which after firing call all message receivers with the same message_identifier
      # @return [Array<Message>]
      def message_senders
        cache(:message_senders) { messages.select(&:sender?) }
      end

      # Message receivers are automated transitions which are fired after one of message senders with the same identifier has been fired
      # @return [Array<Message>]
      def message_receivers
        cache(:message_receivers) { messages.select(&:receiver?) }
      end

      # @param identifier [String]
      # @return [Message, nil]
      def message_sender_by_identifier(identifier)
        message_senders.find { |message| message.message_identifier == identifier }
      end

      # @param identifier [String]
      # @return [Message, nil]
      def message_receiver_by_identifier(identifier)
        message_receivers.find { |message| message.message_identifier == identifier }
      end
    end
  end
end
