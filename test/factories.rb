module Factories
  extend ActiveSupport::Concern

  included do
    let(:user) { User.create!(first_name: "John", last_name: "Doe") }
    let(:order) do
      Order.create!(user_id: user.id, paid: 100.00).tap do |order|
        order.items.create!(name: "Item 1", price: 10.00, quantity: 1)
        order.items.create!(name: "Item 2", price: 20.00, quantity: 2)
      end
    end
  end
end
