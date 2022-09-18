class Item < ActiveRecord::Base
  belongs_to :order, inverse_of: :items
end
