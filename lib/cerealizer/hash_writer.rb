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
      puts_debug("push_object #{key.inspect}")
    end

    def push_value(value, key)
      current[key] = value
      puts_debug("push_value #{key}, #{value}")
    end

    def push_array(key)
      @current = current[key] = [ ]
      stack.push(current)
      puts_debug("push_array #{key}")
    end

    def pop
      stack.pop
      @current = stack.last
      puts_debug("pop")
    end

    def value
      hash[nil]
    end

    private

    def puts_debug(s)
      return unless ENV["DEBUG"]
      puts s
      puts "  stack: #{stack}"
      puts "  current: #{current}"
      puts "  #{hash}\n\n"
    end
  end
end
