module Cerealizer
  class HashWriter
    attr_reader :hash

    def initialize
      @hash = { }
    end

    def push_object(value=nil, key=nil)
      # puts "push_object #{key}, #{value}"
      if key
        hash[key] = value
      end
    end

    def push_value(value, key)
      # puts "push_value #{key}, #{value}"
      hash[key] = value
    end

    def push_array(key)
      # puts "push_array #{key}"
      hash[key] = [ ]
    end

    def push_array_item(value, key)
      # puts "push_array_item #{key}, #{value}"
      hash[key] << value
    end

    def pop
      # do nothing
    end

    def value
      hash
    end
  end
end
