# frozen_string_literal: true
module Petri
  class TaskTransition < Transition
    include Petri::Subprocess

    element_attribute :task_identifier, :pin

    # @param net [Net]
    # @param data [Hash<Symbol>]
    def initialize(net, data = {})
      super
      @task_identifier = @data[:task_identifier]
      @data[:identifier] = generate_identifier
    end

    def create?
      pin == 'Create'
    end

    def finish?
      pin == 'Finish'
    end

    def pause?
      pin == 'Pause'
    end

    def resume?
      pin == 'Resume'
    end

    def cancel?
      pin == 'Cancel'
    end

    def task_identifiers
      task_identifier.present? ? task_identifier.split(/,\W*/) : []
    end

    # [Petri::Subprocess]
    alias subprocess_identifier task_identifier

    private

    def generate_identifier
      if create?
        "Create \"#{task_identifier}\" task"
      elsif finish?
        "Finish \"#{task_identifier}\" task"
      elsif pause?
        "Pause \"#{task_identifier}\" task"
      elsif resume?
        "Resume \"#{task_identifier}\" task"
      elsif cancel?
        "Cancel \"#{task_identifier}\" task"
      end
    end
  end
end
