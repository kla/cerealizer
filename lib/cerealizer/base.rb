module Cerealizer
  class Base
    class_attribute :_attributes
    attr_reader :object, :serialization_options

    def self.attributes(*names)
      Array(names).flatten.each { |name| attribute(name) }
    end

    def self.attribute(name, options={})
      add_attribute(name, :simple, options)
    end

    def self.has_one(name, options={})
      raise ArgumentError, "has_one requires a serializer option" unless options[:serializer]
      self.add_attribute(name, :has_one, options)
    end

    def self.has_many(name, options={})
      raise ArgumentError, "has_many requires a serializer option" unless options[:serializer]
      self.add_attribute(name, :has_many, options)
    end

    def self.add_attribute(name, type, options)
      self._attributes ||= [ ]
      self._attributes << Attribute.new(name, type, options)
    end

    def initialize(object, options={})
      @object = object
      @serialization_options = options
    end

    def serialize(writer)
      self.class._attributes.each do |attribute|
        next unless attribute.include?(self)
        attribute.fetch_value(self, writer)
      end

      writer
    end

    def serializable_hash
      return nil unless object
      serialize_to_writer(HashWriter.new).value
    end
    alias_method :as_json, :serializable_hash

    def to_json
      return "null" unless object
      serialize_to_writer(JsonStringWriter.new).value
    end

    private

    def serialize_to_writer(writer)
      writer.push_object
        writer.push_object(object.class.name.underscore) if serialization_options[:include_root]
          serialize(writer)
        writer.pop if serialization_options[:include_root]
      writer.pop
      writer
    end
  end
end
