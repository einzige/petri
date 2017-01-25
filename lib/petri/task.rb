# frozen_string_literal: true
module Petri
  class Task < Element
    element_attribute :guid, :task_identifier, :manual_finish_enabled
    alias manual_finish_enabled? manual_finish_enabled
  end
end
