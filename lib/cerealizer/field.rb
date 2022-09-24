module Cerealizer
  class Field
    attr_reader :name, :type, :field_options

    def initialize(name, type, options={})
      @name = name.to_sym
      @type = type.to_sym
      @field_options = { }
      @field_options[:method] = options[:method] if options[:method]
      @field_options[:if] = options[:if] if options[:if]
      @field_options[:tags] = Array(options[:tags]).map(&:to_sym) if options[:tags]
      # @field_options[:tags] = options[:tags] ? Array(options[:tags]).map(&:to_sym) : [ ]
      @field_options.merge!(options.slice(:serializer)) if association?
    end

    def include?(serializer, options_array)
      # no need to do all the checks for this common case
      # return true if simple? && !field_options
      return true if field_options.blank?

      options_array.detect do |options|
        if field_options[:tags].present?
          options[:tags].present? ? (field_options[:tags] & Array(options[:tags])).length > 0 : false
        elsif field_options[:if]
          run_proc(field_options[:if], serializer)
        elsif options[:exclude_associations] && association?
          false
        else
          true
        end
      end
    end

    def run_proc(callable, serializer)
      return serializer.instance_exec(&callable) if callable.is_a?(Proc)
      return serializer.send(callable) if serializer.respond_to?(callable)
      raise ArgumentError, "The :if option must be proc or method name"
    end

    def fetch_value(serializer, options_array)
      case type
      when :simple
        fetch_simple(serializer)
      when :has_one
        fetch_has_one_association(serializer, options_array)
      when :has_many
        fetch_has_many_association(serializer, options_array)
      end
    end

    def simple?
      type == :simple
    end

    def association?
      type == :has_one || type == :has_many
    end

    private

    def fetch_simple(serializer)
      object = serializer.object

      if method = field_options[:method]
        object.respond_to?(method) ? object.send(method) : serializer.send(method)
      else
        object.send(name)
      end
    end

    def fetch_has_one_association(serializer, options_array)
      assoc_object = fetch_simple(serializer)
      field_options[:serializer].new(assoc_object).serializable_hash(options_array)
    end

    def fetch_has_many_association(serializer, options_array)
      ser = field_options[:serializer].new(nil)
      fetch_simple(serializer).map do |assoc_object|
        ser.instance_variable_set(:@object, assoc_object)
        ser.serializable_hash(options_array)
      end
    end
  end
end
