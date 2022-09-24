module Cerealizer
  class Base
    class_attribute :fields
    attr_reader :object

    def self.attributes(*names)
      Array(names).flatten.each { |name| attribute(name) }
    end

    def self.attribute(name, options={})
      add_field(name, :simple, options)
    end

    def self.has_one(name, options={})
      raise ArgumentError, "has_one requires a serializer option" unless options[:serializer]
      self.add_field(name, :has_one, options)
    end

    def self.has_many(name, options={})
      raise ArgumentError, "has_many requires a serializer option" unless options[:serializer]
      self.add_field(name, :has_many, options)
    end

    def self.add_field(name, type, options)
      self.fields ||= [ ]
      self.fields << Field.new(name, type, options)
    end

    def initialize(object)
      @object = object
    end

    def serializable_hash(options={})
      return nil unless object

      self.class.fields.each_with_object({}) do |field, hash|
        next unless field.include?(self, options)
        hash[field.name] = field.fetch_value(self, options)
      end
    end

    def as_json(options={})
      serializable_hash(options).as_json
    end

    def to_json(options={})
      MultiJson.dump(serializable_hash(options))
    end
  end
end
