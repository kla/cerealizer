require_relative "./setup"

module Serializers
  module Cerealizer
    class OrderSerializer < ::Cerealizer::Base
      attributes :id, :created_at, :updated_at, :paid

      def self.serialize(object)
        new.to_json(object)
      end
    end
  end

  module Ams
    class OrderSerializer < ::ActiveModel::Serializer
      attributes :id, :created_at, :updated_at, :paid

      def self.serialize(object)
        new(object).to_json
      end
    end
  end

  module JsonApi
    class OrderSerializer
      include JSONAPI::Serializer
      attributes :id, :created_at, :updated_at, :paid

      def self.serialize(object)
        new(object).to_json
      end
    end
  end

  module JbuilderEncode
    class OrderSerializer
      def initialize(order)
        @order = order
      end

      def self.serialize(object)
        new(object).to_json
      end

      def to_json
        ::Jbuilder.encode do |json|
          json.order do
            json.id @order.id
            json.created_at @order.created_at
            json.updated_at @order.updated_at
            json.paid @order.paid
          end
        end
      end
    end
  end

  module Alba
    class OrderSerializer
      include ::Alba::Resource
      attributes :id, :created_at, :updated_at, :paid

      def self.serialize(object)
        new(object).serialize
      end
    end
  end

  module Panko
    class OrderSerializer < ::Panko::Serializer
      attributes :id, :created_at, :updated_at, :paid

      def self.serialize(object)
        new.serialize_to_json(object)
      end
    end
  end

  module Hash
    class OrderSerializer
      def initialize(order)
        @order = order
      end

      def self.serialize(object)
        new(object).to_json
      end

      def to_json
        MultiJson.dump(id: @order.id, created_at: @order.created_at, updated_at: @order.updated_at, paid: @order.paid)
      end
    end
  end
end

Setup.benchmark("Serializers::#{ARGV[0]}".constantize, ARGV[1].to_i, ARGV[2] == "true")
