class Order < ActiveRecord::Base
  belongs_to :user
  has_many :items, inverse_of: :order
end
