# frozen_string_literal: true
module Petri
  module NetLoader
    module Tasks
      # @param guid [String]
      # @param task_identifier [String]
      # @param manual_finish_enabled [Boolean]
      # @return [Task]
      def add_task(**data)
        add_task_transition(task_identifier: data[:task_identifier], pin: 'Finish', automated: false) if data[:manual_finish_enabled]
        add_task_transition(task_identifier: data[:task_identifier], pin: 'Cancel', automated: false) # Manual cancel is always enabled for system?
        ::Petri::Task.new(self, **data).tap { |task| @tasks << task }
      end

      private

      # @param task_identifier [String]
      # @param pin [String] transition name in a tasks subflow to trigger when task transition fires in a parent flow: Create, Finish, Cancel, Pause etc
      # @param automated [Boolean]
      def add_task_transition(**data)
        add_task_transition_node(new_task_transition(**data))
      end

      # @param task_transition [TaskTransition]
      # @return [TaskTransition]
      def add_task_transition_node(task_transition)
        task_transition.tap { @transitions << task_transition }
      end

      # @param task_identifier [String] not a transition identifier, but task identifier, example: reach_out_to_client
      # @param pin [String] transition name in a tasks subflow to trigger when task transition fires in a parent flow: Create, Finish, Cancel, Pause etc
      # @param automated [Boolean]
      # @param process_class [String] a class name implementing tasks subrocess behavior
      # @return [TaskTransition]
      def new_task_transition(task_identifier:, pin:, automated:, process_class: tasks_process_class)
        ::Petri::TaskTransition.new(self, task_identifier: task_identifier, pin: pin, automated: automated, process_class: process_class || tasks_process_class)
      end
    end
  end
end
