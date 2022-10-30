module Cerealizer
  class Attribute
    attr_reader :name, :type, :attribute_options

    def initialize(name, type, options={})
      @name = name.to_s
      @type = type.to_sym
      @attribute_options = { }
      @attribute_options[:method] = options[:method] if options[:method]
      @attribute_options[:if] = options[:if] if options[:if]
      @attribute_options[:serialization_options] = options[:serialization_options] if options[:serialization_options]

      if association?
        @serializer = options[:serializer]
        raise ArgumentError, "A :serializer option is required for associations" unless @serializer
      end
    end

    def include?(serializer)
      if attribute_options.blank?
        true
      elsif attribute_options[:if]
        run_proc(attribute_options[:if], serializer)
      else
        true
      end
    end

    def run_proc(callable, serializer)
      return serializer.instance_exec(&callable) if callable.is_a?(Proc)
      return serializer.public_send(callable) if serializer.respond_to?(callable)
      raise ArgumentError, "The :if option must be proc or method name"
    end

    def fetch_value(serializer, writer)
      if type == :simple
        fetch_simple(serializer, writer)
      elsif type == :has_one
        fetch_has_one(serializer, writer)
      elsif type == :has_many
        fetch_has_many(serializer, writer)
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

      if method = attribute_options[:method]
        serializer.send(method)
      else
        serializer.respond_to?(name) ? serializer.send(name) : object.public_send(name)
      end
    end

    def fetch_simple(serializer, writer)
      value = get_value(serializer)
      writer.push_value(name, value)
      value
    end

    def build_association_options(serializer)
      options = attribute_options[:serialization_options]

      if serializer.params
        options ||= { }
        options = options.merge(params: serializer.params)
      end

      options
    end

    def fetch_has_one(serializer, writer)
      unless (assoc_object = get_value(serializer)) == nil
        writer.push_object(name)
          @serializer.new(build_association_options(serializer)).serialize_attributes(writer, assoc_object)
        writer.pop
      else
        writer.push_value(name, nil)
      end
    end

    def fetch_has_many(serializer, writer)
      writer.push_array(name)
      has_many_serializer = @serializer.new(build_association_options(serializer))

      get_value(serializer).each do |assoc_object|
        writer.push_object
          has_many_serializer.serialize_attributes(writer, assoc_object)
        writer.pop
      end

      writer.pop
    end
  end
end
