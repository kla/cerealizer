module Cerealizer
  class JsonStringWriter
    attr_reader :writer

    def initialize
      @writer = Oj::StringWriter.new
    end

    def push_object(key=nil)
      # puts "push_object #{key}, #{value}"
      writer.push_object(key)
    end

    def push_value(key, value)
      # puts "push_value #{key}, #{value}"
      if value.is_a?(Time)
        value = value.iso8601(3)
      elsif value.is_a?(BigDecimal)
        value = value.to_s
      end
      writer.push_value(value, key)
    end

    def push_array(key)
      # puts "push_array #{key}"
      writer.push_array(key ? key : nil)
    end

    def push_array_item(key, value)
      # puts "push_array_item #{key}, #{value}"
    end

    def pop
      # puts "pop"
      writer.pop
    end

    def pop_all
      writer.pop_all
    end

    def value
      writer.to_s.rstrip
    end
  end
end
