# frozen_string_literal: true
module Petri
  module Subprocess
    # Used as a key for caching
    # @return [String]
    def subprocess_identifier
      raise NotImplementedError
    end

    # @return [Class]
    def process_class
      @process_class ||= self[:process_class].constantize
    end
  end
end
