module Factories
  extend ActiveSupport::Concern

  included do
    if respond_to?(:let)
      let(:user) { create_user }
      let(:order) { create_order(user) }
    end
  end

  def create_user
    User.create!(first_name: "John", last_name: "Doe")
  end

  def create_order(user=create_user, num_items=2)
    Order.create!(user_id: user.id, paid: 100.00).tap do |order|
      num_items.times do |i|
        i = i + 1
        order.items.create!(name: "Item #{i}", price: i * 10, quantity: i)
      end
    end
  end
end
