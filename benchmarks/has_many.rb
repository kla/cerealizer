require_relative "./setup"

module Cerealizer
  class ItemSerializer < ::Cerealizer::Base
    attributes :id, :order_id, :created_at, :updated_at, :name, :price, :quantity
  end

  class OrderSerializer < ::Cerealizer::Base
    attributes :id, :created_at, :updated_at, :paid
    has_many :items, serializer: ItemSerializer
  end

  def self.benchmark
    Cerealizer::OrderSerializer.new(Order.first).to_json
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

  def self.benchmark
    Ams::OrderSerializer.new(Order.first).to_json
  end
end

module JsonApi
  class ItemSerializer
    include JSONAPI::Serializer
    attributes :id, :created_at, :updated_at, :paid
  end

  class OrderSerializer
    include JSONAPI::Serializer
    attributes :id, :created_at, :updated_at, :paid
    has_many :items, serializer: ItemSerializer
  end

  def self.benchmark
    JsonApi::OrderSerializer.new(Order.first).to_json
  end
end

Setup.benchmark([ Cerealizer, Ams, JsonApi ], ARGV[0])
