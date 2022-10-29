require_relative "./user_serializer"
require_relative "./item_serializer"

module Serializers
  class OrderSerializer < Cerealizer::Base
    attributes :id, :created_at, :updated_at, :paid
    has_one :user, serializer: UserSerializer
    has_many :items, serializer: ItemSerializer
  end
end
