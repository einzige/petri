module Petri
  module NetLoader
    # @param val [String, Class]
    def tasks_process_class=(val)
      @tasks_process_class = val
    end

    # @return [String, Class]
    def tasks_process_class
      @tasks_process_class || 'TasksProcess'
    end

    # @param guid [String]
    # @param identifier [String]
    # @param start [true, false]
    def add_place(guid: nil, identifier: , start: false, finish: false)
      Place.new(self, {guid: guid, identifier: identifier, start: start, finish: finish}).tap do |place|
        @places << place
      end
    end

    # @param guid [String]
    # @param identifier [String]
    # @param action [String]
    def add_transition(guid: nil, identifier: , action: nil, automated: )
      Transition.new(self, {guid: guid, identifier: identifier, action: action, automated: automated}).tap do |transition|
        @transitions << transition
      end
    end

    # @param guid [String]
    # @param identifier [String]
    # @param action [String]
    def add_message(guid: nil, identifier:)
      Message.new(self, {guid: guid, identifier: identifier}).tap do |message|
        @transitions << message
      end
    end

    # @param task_identifier [String]
    # @param pin [String]
    # @param automated [true, false]
    def add_task_transition(task_identifier:, pin:, automated:)
      TaskTransition.new(self, {task_identifier: task_identifier, pin: pin, automated: automated, process_class: tasks_process_class}).tap do |transition|
        @transitions << transition
      end
    end

    # @param guid [String]
    # @param identifier [String]
    # @param from_guid [String]
    # @param to_guid [String]
    # @param type [String]
    # @param production_rule [String, nil]
    def add_arc(guid: nil, from_guid: , to_guid: , type: , production_rule: nil, guard: nil, timer_rule: nil)
      from_node = node_by_guid(from_guid)
      to_node = node_by_guid(to_guid)

      if type == 'test'
        @arcs << Arc.new(self, from: from_node, to: to_node, type: :regular, guid: guid, guard: guard, timer_rule: timer_rule)
        @arcs << Arc.new(self, from: to_node, to: from_node, type: :regular, guid: guid)
      else
        @arcs << Arc.new(self, from: from_node, to: to_node, type: type.try(:to_sym), guid: guid, production_rule: production_rule, guard: guard, timer_rule: timer_rule)
      end
    end

    # @param task_data [Hash]
    # @param net_data [Hash] full bpf
    def add_task(task_data, net_data)
      identifier = task_data['identifier']

      add_task_transition(task_identifier: identifier, pin: 'Finish', automated: false) if task_data['manual_finish_enabled']
      add_task_transition(task_identifier: identifier, pin: 'Cancel', automated: false) # Manual cancel is always enabled?

      task_arcs = net_data['arcs'].select { |arc| arc['to_guid'] == task_data['guid'] }.group_by { |arc| arc['pin'] }
      task_arcs.each { |pin, arcs| connect_task_arcs(identifier, pin, arcs) }
    end

    # @param task_identifier [String]
    # @param pin [String] Create, Pause, Finish, Cancel
    # @param arcs [Array<Petri::Arc>]
    def connect_task_arcs(task_identifier, pin, arcs)
      return if arcs.empty?

      transition = add_task_transition(task_identifier: task_identifier, pin: pin, automated: true)

      # (p*) <?-> [(T) task pin]
      arcs.each_with_index do |arc, index|
        front_arc_type = arc['type'] == 'test' ? 'regular' : arc['type']

        add_arc(from_guid: arc['from_guid'],
                to_guid: transition.guid,
                type: front_arc_type,
                guard: arc['guard'],
                timer_rule: arc['timer_rule'])

        add_arc(from_guid: transition.guid,
                to_guid: arc['from_guid'],
                type: 'regular') if arc['type'] == 'test'
      end
    end

    def self.included(base_class)
      base_class.extend(ClassMethods)
    end

    module ClassMethods

      # @param path [String]
      # @return [Net]
      def from_file(path)
        from_stream(File.new(path))
      end

      # @param io [IO]
      # @return [Net]
      def from_stream(io)
        from_string(io.read)
      end

      # @param str [String]
      # @return [Net]
      def from_string(str)
        from_hash(JSON.parse(str))
      end

      # @param hash [Hash<String>]
      # @return [Net]
      def from_hash(hash)
        self.new.tap do |net|
          hash['places'].each do |data|
            net.add_place(guid: data['guid'],
                          identifier: data['identifier'],
                          start: data['start'],
                          finish: data['finish'])
          end

          hash['transitions'].each do |data|
            net.add_transition(guid: data['guid'],
                               identifier: data['identifier'],
                               automated: data['automated'],
                               action: data['action'])
          end

          hash['messages'].each do |data|
            net.add_message(guid: data['guid'],
                            identifier: data['identifier'])
          end if hash['messages']

          hash['tasks'].each do |data|
            net.add_task(data, hash)
          end if hash['tasks']

          hash['arcs'].each do |data|
            net.add_arc(guid: data['guid'],
                        from_guid: data['from_guid'],
                        to_guid: data['to_guid'],
                        type: data['type'],
                        production_rule: data['production_rule'],
                        timer_rule: data['timer_rule'],
                        guard: data['guard'])
          end
        end
      end
    end
  end
end
