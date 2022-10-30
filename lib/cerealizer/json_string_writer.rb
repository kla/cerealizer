module Cerealizer
  class JsonStringWriter
    attr_reader :writer

    def initialize
      @writer = Oj::StringWriter.new
    end

    def push_object(key=nil)
      writer.push_object(key)
    end

    def push_value(key, value)
      if value.is_a?(Time)
        value = value.iso8601(3)
      elsif value.is_a?(BigDecimal)
        value = value.to_s
      end

      if value.is_a?(Hash) || value.is_a?(Array)
        # So that symbolized hash keys get written correctly
        writer.push_json(value.to_json, key)
      else
        writer.push_value(value, key)
      end
    end

    def push_array(key)
      writer.push_array(key)
    end

    def pop
      writer.pop
    end

    def value
      writer.to_s.rstrip
    end
  end
end
