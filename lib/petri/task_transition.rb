module Petri
  class TaskTransition < Transition
    include Petri::Subprocess

    attr_reader :task_identifier

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

    def pin
      @data[:pin]
    end

    # [Petri::Subprocess]
    def subprocess_identifier
      task_identifier
    end

    private

    def generate_identifier
      if create?
        "Create \"#{@task_identifier}\" task"
      elsif finish?
        "Finish \"#{@task_identifier}\" task"
      elsif pause?
        "Pause \"#{@task_identifier}\" task"
      elsif resume?
        "Resume \"#{@task_identifier}\" task"
      elsif cancel?
        "Cancel \"#{@task_identifier}\" task"
      end
    end
  end
end
