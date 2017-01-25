# frozen_string_literal: true
module Petri
  module NetLoader
    module Arcs
      # Adds petri net arc into the net
      # @param from_node [Node]
      # @param to_node [Node]
      # @param type [Symbol] regular, reset or inhibitor
      # @param guard [String, nil]
      # @param timer_rule [String, nil]
      # @return [Arc]
      def add_basic_arc(from_node, to_node, type: :regular, guard: nil, timer_rule: nil)
        raise ArgumentError unless [:regular, :reset, :inhibitor].include?(type)
        Arc.new(self, from_node: from_node, to_node: to_node, type: type, guard: guard, timer_rule: timer_rule).tap { |arc| @arcs << arc }
      end

      # @param from_node [Node]
      # @param to_node [Node]
      # @param guard [String, nil]
      # @param timer_rule [String, nil]
      def add_test_arc(from_node, to_node, guard: nil, timer_rule: nil)
        add_basic_arc(from_node, to_node, guard: guard, timer_rule: timer_rule)
        add_basic_arc(to_node, from_node)
      end

      # Connects two places inserting an automated transition between them. Used as a shortcut for "OR" statements or just to reduce number of intersections
      # Performs transformation like so: (p) ~> (p) => (p) ~> [T] -> (p)
      # @param from_node [Node]
      # @param to_node [Node]
      # @param type [Symbol] regular, inhibitor, test or reset
      # rubocop:disable Metrics/AbcSize
      def add_from_place_to_place_arc(from_place, to_place, type:)
        new_transition_identifier = "AFTER '#{from_place.identifier}' PLACE VIA #{type}"
        new_transition = message_sender_by_identifier(new_transition_identifier) || add_message(identifier: new_transition_identifier, type: :sender)

        if type == :reset
          add_arc(from_guid: from_place.guid, to_guid: new_transition.guid, type: :test)
          add_arc(from_guid: new_transition.guid, to_guid: to_place.guid, type: :reset)
        else
          add_arc(from_guid: from_place.guid, to_guid: new_transition.guid, type: type)
          add_arc(from_guid: new_transition.guid, to_guid: to_place.guid, type: :regular)
        end
      end

      # Connects two transitions inserting a new generated between them. Used to reduce number of extra nodes on the diagram.
      # Performs transformation like: [T] ~> [T] => [T] -> (p) ~> [T]
      # @param from_node [Node]
      # @param to_node [Node]
      # @param guard [String, nil]
      # @param timer_rule [String, nil]
      def add_from_transition_to_transition_arc(from_transition, to_transition, guard: nil, timer_rule: nil)
        persisted = guard.present? || timer_rule.present? || to_transition.input_arcs.many?
        new_place = add_place(identifier: "FROM '#{from_transition.identifier}' TO '#{to_transition.identifier}'", persisted: persisted)
        add_basic_arc(from_transition, new_place)
        add_basic_arc(new_place, to_transition, guard: guard, timer_rule: timer_rule)
      end

      # Creates a set of nodes to handle tasks behavior
      # @param from_node [Node]
      # @param to_node [Node]
      # @param pin [String] transition name in a tasks subflow to trigger when task transition fires in a parent flow: Create, Finish, Cancel, Pause etc
      # @param type [Symbol] regular, inhibitor, test or reset
      # @param guard [String, nil]
      # @param timer_rule [String, nil]
      def add_task_arc(from_node, to_task, pin:, type: :regular, **data)
        task_transition = new_task_transition(task_identifier: to_task.task_identifier, pin: pin, automated: true)
        existing_transition = transition_by_identifier(task_transition.identifier, automated: true)

        if existing_transition
          task_transition = existing_transition
        else
          add_task_transition_node(task_transition)
        end

        add_arc(from_node: from_node, to_node: task_transition, type: type, **data)
      end

      # @param from_guid [String, nil]
      # @param to_guid [String, nil]
      # @param from_node [Node, nil]
      # @param to_node [Node, nil]
      # @param type [Symbol]
      # @param guard [String, nil]
      # @param timer_rule [String, nil]
      # @param pin [String] used for tasks only, transition name in a tasks subflow to trigger when task transition fires in a parent flow: Create, Finish, Cancel, Pause etc
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/ParameterLists
      def add_arc(from_guid: nil, from_node: node_by_guid(from_guid),
                  to_guid: nil, to_node: node_by_guid(to_guid),
                  type:, guard: nil, timer_rule: nil, pin: nil)

        raise ArgumentError, 'Missing arc base node' unless from_node
        raise ArgumentError, 'Missing arc target node' unless to_node

        type = type&.to_sym

        if to_node.is_a?(Petri::Task)
          add_task_arc(from_node, to_node, pin: pin, type: type, guard: guard, timer_rule: timer_rule)
        elsif from_node.is_a?(Petri::Place) && to_node.is_a?(Petri::Place)
          add_from_place_to_place_arc(from_node, to_node, type: type)
        elsif from_node.is_a?(Petri::Transition) && to_node.is_a?(Petri::Transition)
          add_from_transition_to_transition_arc(from_node, to_node, guard: guard, timer_rule: timer_rule)
        elsif type == :test
          add_test_arc(from_node, to_node, guard: guard, timer_rule: timer_rule)
        else
          add_basic_arc(from_node, to_node, type: type, guard: guard, timer_rule: timer_rule)
        end
      end
    end
  end
end
