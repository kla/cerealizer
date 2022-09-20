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

  def create_order(user=create_user)
    Order.create!(user_id: user.id, paid: 100.00).tap do |order|
      order.items.create!(name: "Item 1", price: 10.00, quantity: 1)
      order.items.create!(name: "Item 2", price: 20.00, quantity: 2)
    end
  end
end
