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

    def serialize(writer, options={})
      if object
        # puts "serialize #{options}"
        writer.push_object(options[:key])

        self.class.fields.each do |field|
          next unless field.include?(self, options)
          field.fetch_value(self, writer, options)
        end
        writer.pop
      else
        writer.is_a?(HashWriter) ? nil : "null"
      end

      writer
    end

    def serializable_hash(options={})
      # serialize(HashWriter.new, options).value
      JSON.parse(to_json(options))
    end
    alias_method :as_json, :serializable_hash

    def to_json(options={})
      serialize(JsonStringWriter.new, options).value
    end
  end
end
