require_relative "./setup"

module Cerealizer
  class ItemSerializer < ::Cerealizer::Base
    attributes :id, :order_id, :created_at, :updated_at, :name, :price, :quantity
  end

  class OrderSerializer < ::Cerealizer::Base
    attributes :id, :created_at, :updated_at, :paid
    has_many :items, serializer: ItemSerializer
  end
end

module Ams
  class ItemSerializer < ::ActiveModel::Serializer
    attributes :id, :order_id, :created_at, :updated_at, :name, :price, :quantity
  end

  class OrderSerializer < ::ActiveModel::Serializer
    attributes :id, :created_at, :updated_at, :paid
    has_many :items, serializer: ItemSerializer
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
  end
end

module Jbuildr
  class OrderSerializer
    def initialize(order)
      @order = order
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
              json.created_at item.updated_at
              json.name item.name
              json.price item.quantity
            end
          end
        end
      end
    end
  end
end

module Alba
  class ItemSerializer
    include Alba::Resource
    attributes :id, :order_id, :created_at, :updated_at, :name, :price, :quantity
  end

  class OrderSerializer
    include Alba::Resource
    attributes :id, :created_at, :updated_at, :paid
    many :items, resource: ItemSerializer
  end
end

Setup.benchmark([ Cerealizer, Ams, JsonApi, Jbuildr, Alba ], ARGV[0])
