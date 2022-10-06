module Cerealizer
  class HashWriter
    attr_reader :hash
    attr_reader :stack
    attr_reader :current

    def initialize
      @hash = @current = { }
      @stack = [ ]
    end

    def push_object(key=nil)
      unless @current.is_a?(Array)
        @current = @current[key] = { }
      else
        @current.push(@current = { })
      end

      stack.push(current)
    end

    def push_value(key, value)
      current[key] = value
    end

    def push_array(key)
      @current = current[key] = [ ]
      stack.push(current)
    end

    def pop
      stack.pop
      @current = stack.last
    end

    def value
      hash[nil]
    end
  end
end
