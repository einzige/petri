module Petri
  module Subprocess

    # Used as a key for caching
    # @return [String]
    def subprocess_identifier
      fail NotImplementedError
    end

    # @return [Class]
    def process_class
      @process_class ||= begin
        klass = @data[:process_class]
        case klass
        when String
          klass.constantize
        when Class
          klass
        else
          fail ArgumentError, "Expected Class, String, got #{klass.class.name}"
        end
      end
    end
  end
end
