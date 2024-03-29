require_relative "./setup"

module Serializers
  module Cerealizer
    class ItemSerializer < ::Cerealizer::Base
      attributes :id, :order_id, :created_at, :updated_at, :name, :price, :quantity
    end

    class OrderSerializer < ::Cerealizer::Base
      attributes :id, :created_at, :updated_at, :paid
      has_many :items, serializer: ItemSerializer

      def self.serialize(object)
        new.to_json(object)
      end
    end
  end

  module Ams
    class ItemSerializer < ::ActiveModel::Serializer
      attributes :id, :order_id, :created_at, :updated_at, :name, :price, :quantity
    end

    class OrderSerializer < ::ActiveModel::Serializer
      attributes :id, :created_at, :updated_at, :paid
      has_many :items, serializer: ItemSerializer

      def self.serialize(object)
        new(object).to_json
      end
    end
  end

  module JsonApi
    class ItemSerializer
      include JSONAPI::Serializer
      attributes :id, :order_id, :created_at, :updated_at, :name, :price, :quantity
    end

    class OrderSerializer
      include JSONAPI::Serializer
      attributes :id, :created_at, :updated_at, :paid
      has_many :items, serializer: ItemSerializer

      def self.serialize(object)
        new(object, include: %i[ items ]).to_json
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
        Jbuilder.encode do |json|
          json.order do
            json.id @order.id
            json.created_at @order.created_at
            json.updated_at @order.updated_at
            json.paid @order.paid
            json.items do
              json.array! @order.items do |item|
                json.id item.id
                json.order_id item.order_id
                json.created_at item.created_at
                json.updated_at item.updated_at
                json.name item.name
                json.price item.price
                json.quantity item.quantity
              end
            end
          end
        end
      end
    end
  end

  module Alba
    class ItemSerializer
      include ::Alba::Resource
      attributes :id, :order_id, :created_at, :updated_at, :name, :price, :quantity
    end

    class OrderSerializer
      include ::Alba::Resource
      attributes :id, :created_at, :updated_at, :paid
      many :items, resource: ItemSerializer

      def self.serialize(object)
        new(object).serialize
      end
    end
  end

  module Panko
    class ItemSerializer < ::Panko::Serializer
      attributes :id, :order_id, :created_at, :updated_at, :name, :price, :quantity
    end

    class OrderSerializer < ::Panko::Serializer
      attributes :id, :created_at, :updated_at, :paid
      has_many :items, serializer: ItemSerializer

      def self.serialize(object)
        new.serialize_to_json(object)
      end
    end
  end

  module Hash
    class ItemSerializer
      attr_accessor :item

      def initialize(item)
        @item = item
      end

      def serializable_hash
        {
          id: @item.id,
          order_id: @item.order_id,
          created_at: @item.created_at,
          updated_at: @item.updated_at,
          name: @item.name,
          price: @item.price,
          quantity: @item.quantity,
        }
      end
    end

    class OrderSerializer
      def initialize(order)
        @order = order
      end

      def self.serialize(object)
        new(object).to_json
      end

      def serializable_hash
        item_serializer = ItemSerializer.new(nil)
        {
          id: @order.id,
          created_at: @order.created_at,
          updated_at: @order.updated_at,
          paid: @order.paid,
          items: @order.items.map do |item|
            item_serializer.item = item
            item_serializer.serializable_hash
          end
        }
      end

      def to_json
        MultiJson.dump(serializable_hash)
      end
    end
  end
end

Setup.benchmark("Serializers::#{ARGV[0]}".constantize, ARGV[1].to_i, ARGV[2] == "true")
