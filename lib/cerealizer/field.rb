module Cerealizer
  class Field
    attr_reader :name, :type, :field_options

    def initialize(name, type, options={})
      @name = name.to_s
      @type = type.to_sym
      @field_options = { }
      @field_options[:method] = options[:method] if options[:method]
      @field_options[:if] = options[:if] if options[:if]
      @field_options[:tags] = Array(options[:tags]).map(&:to_sym) if options[:tags]
      # @field_options[:tags] = options[:tags] ? Array(options[:tags]).map(&:to_sym) : [ ]

      if association?
        @serializer = options[:serializer]
        raise ArgumentError, "A :serializer option is required for associations" unless @serializer
      end
    end

    def include?(serializer, options={})
      # no need to do all the checks for this common case
      return true if field_options.blank?

      if field_options[:tags].present?
        options[:tags].present? ? (field_options[:tags] & Array(options[:tags])).length > 0 : false
      elsif field_options[:if]
        run_proc(field_options[:if], serializer)
      # elsif options[:exclude_associations] && association?
      #   false
      else
        true
      end
    end

    def run_proc(callable, serializer)
      return serializer.instance_exec(&callable) if callable.is_a?(Proc)
      return serializer.public_send(callable) if serializer.respond_to?(callable)
      raise ArgumentError, "The :if option must be proc or method name"
    end

    def fetch_value(serializer, writer, options={})
      if type == :simple
        fetch_simple(serializer, writer, options)
      elsif type == :has_one
        fetch_has_one(serializer, writer, options)
      elsif type == :has_many
        fetch_has_many(serializer, writer, options)
      end
    end

    def simple?
      type == :simple
    end

    def association?
      type == :has_one || type == :has_many
    end

    private

    def get_value(serializer)
      object = serializer.object

      if method = field_options[:method]
        object.respond_to?(method) ? object.public_send(method) : serializer.public_send(method)
      else
        object.public_send(name)
      end
    end

    def fetch_simple(serializer, writer, options={})
      value = get_value(serializer)
      writer.push_value(value, name)
      value
    end

    def fetch_has_one(serializer, writer, options)
      assoc_object = get_value(serializer)
      serializer = @serializer.new(assoc_object)
      serializer.serialize(writer, options.merge(key: name))
    end

    def fetch_has_many(serializer, writer, options)
      # puts "!!!!!!!!!!!!!!! has_many"
      writer.push_array(name)
      ser = @serializer.new(nil)

      get_value(serializer).each do |assoc_object|
        ser.instance_variable_set(:@object, assoc_object)
        ser.serialize(writer, options)
        # writer.push_array_item(value, name)
      end

      writer.pop
    end
  end
end
