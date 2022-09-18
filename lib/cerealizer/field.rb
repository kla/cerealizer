module Cerealizer
  class Field
    attr_reader :name, :type, :field_options

    def initialize(name, type, options={})
      @name = name.to_sym
      @type = type.to_sym
      @field_options = options.slice(:method, :if)
      @field_options[:views] = options[:views] ? Array(options[:views]).map(&:to_sym) : [ ]
      @field_options.merge!(options.slice(:serializer)) if association?
    end

    def include?(serializer, options_array)
      # no need to do all the checks for this common case
      return true if simple? && field_options.blank?

      options_array.detect do |options|
        if field_options[:views].present?
          options[:views].present? ? (field_options[:views] & Array(options[:views])).present? : false
        elsif field_options[:if] && !serializer.instance_exec(options[:locals] || { }, &field_options[:if])
          false
        elsif options[:exclude_associations] && association?
          false
        else
          true
        end
      end
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
