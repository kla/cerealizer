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

    def params
      serialization_options.params
    end

    def serialize_attributes(writer, object)
      @object = object

      attributes.each do |attribute|
        next unless attribute.include?(self)
        attribute.fetch_value(self, writer)
      end

      writer
    ensure
      @object = nil
    end

    def as_json(object)
      return nil unless object
      serialize_to_writer(HashWriter.new, object).value
    end

    def to_json(object)
      return "null" unless object
      serialize_to_writer(JsonStringWriter.new, object).value
    end
    alias_method :serialize, :to_json

    def self.serialize(object, options={})
      new(options).to_json(object)
    end

    def self.serialize_to_hash(object, options={})
      new(options).as_json(object)
    end

    def self.serialize_enumerable(enumerable, options={})
      serializer = new(options)
      writer = JsonStringWriter.new
      writer.push_array("")

      enumerable.each do |object|
        writer.push_object
        serializer.serialize_attributes(writer, object)
        writer.pop
      end

      writer.pop
      value = writer.value
      value.slice(3, value.length) # get rid of the leading: "":
    end

    def serialize_to_writer(writer, object)
      writer.push_object
        writer.push_object(object.class.name.underscore) if serialization_options.include_root
          serialize_attributes(writer, object)
        writer.pop if serialization_options.include_root
      writer.pop
      writer
    end

    private

    def attributes
      @attributes ||= self.class._attributes.each_with_object([ ]) do |attribute, attributes|
        next if serialization_options.exclude_associations && attribute.association?
        next if serialization_options.except && serialization_options.except.include?(attribute.name)
        next if serialization_options.only && !serialization_options.only.include?(attribute.name)
        attributes << attribute
      end
    end
  end
end
