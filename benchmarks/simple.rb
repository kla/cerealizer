require_relative "./setup"

module Cerealizer
  class OrderSerializer < ::Cerealizer::Base
    attributes :id, :created_at, :updated_at, :paid
  end

  def self.benchmark
    OrderSerializer.new(Order.first).to_json
  end
end

module Ams
  class OrderSerializer < ::ActiveModel::Serializer
    attributes :id, :created_at, :updated_at, :paid
  end

  def self.benchmark
    OrderSerializer.new(Order.first).to_json
  end
end

module JsonApi
  class OrderSerializer
    include JSONAPI::Serializer
    attributes :id, :created_at, :updated_at, :paid
  end

  def self.benchmark
    OrderSerializer.new(Order.first).to_json
  end
end

Setup.benchmark([ Cerealizer, Ams, JsonApi ], ARGV[0])
