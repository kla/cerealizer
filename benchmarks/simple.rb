require_relative "./setup"

module Cerealizer
  class OrderSerializer < ::Cerealizer::Base
    attributes :id, :created_at, :updated_at, :paid
  end
end

module Ams
  class OrderSerializer < ::ActiveModel::Serializer
    attributes :id, :created_at, :updated_at, :paid
  end
end

module JsonApi
  class OrderSerializer
    include JSONAPI::Serializer
    attributes :id, :created_at, :updated_at, :paid
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
        end
      end
    end
  end
end

module Alba
  class OrderSerializer
    include Alba::Resource
    attributes :id, :created_at, :updated_at, :paid
  end
end

Setup.benchmark([ Cerealizer, Ams, JsonApi, Jbuildr, Alba ], ARGV[0])
