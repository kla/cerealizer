module Serializers
  class ItemSerializer < Cerealizer::Base
    attributes :id, :order_id, :created_at, :updated_at, :name, :price, :quantity
  end
end
