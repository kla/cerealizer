require_relative "./serialization_options"

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

    def initialize(options={})
      @serialization_options = SerializationOptions.new(options)
    end

    def serialize(writer, object)
      @object = object

      self.class._attributes.each do |attribute|
        next unless attribute.include?(self)
        attribute.fetch_value(self, writer)
      end

      writer
    ensure
      @object = nil
    end

    def serializable_hash(object)
      return nil unless object
      serialize_to_writer(HashWriter.new, object).value
    end
    alias_method :as_json, :serializable_hash

    def to_json(object)
      return "null" unless object
      serialize_to_writer(JsonStringWriter.new, object).value
    end

    private

    def serialize_to_writer(writer, object)
      writer.push_object
        writer.push_object(object.class.name.underscore) if serialization_options.include_root
          serialize(writer, object)
        writer.pop if serialization_options.include_root
      writer.pop
      writer
    end
  end
end
