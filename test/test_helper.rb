require "minitest/autorun"
require "minitest/pride"
require "active_record"
require "oj"
require_relative "../lib/cerealizer"
require_relative "./models/order"
require_relative "./models/user"
require_relative "./models/item"
require_relative "./serializers/item_serializer"
require_relative "./serializers/order_serializer"
require_relative "./serializers/user_serializer"

class TestCase < Minitest::Spec
  let(:user) { User.create!(first_name: "John", last_name: "Doe") }
  let(:order) do
    Order.create!(user_id: user.id, paid: 100.00).tap do |order|
      order.items.create!(name: "Item 1", price: 10.00, quantity: 1)
      order.items.create!(name: "Item 2", price: 20.00, quantity: 2)
    end
  end

  before do
    Order.delete_all
    User.delete_all
    Item.delete_all
  end

  def self.create_database
    ActiveRecord::Migration.create_table(:orders) do |t|
      t.timestamps
      t.references :user
      t.decimal :paid
    end

    ActiveRecord::Migration.create_table(:users) do |t|
      t.timestamps
      t.string :first_name
      t.string :last_name
    end

    ActiveRecord::Migration.create_table(:items) do |t|
      t.timestamps
      t.references :order
      t.string :name
      t.decimal :price
      t.integer :quantity
    end
  end

  def assert_user(expected_user, json)
    assert_equal expected_user.id, json["id"]
    assert_equal expected_user.first_name, json["first_name"]
    assert_equal expected_user.last_name, json["last_name"]
    assert_equal "#{expected_user.first_name} #{expected_user.last_name}", json["full_name"]
    assert_equal expected_user.created_at.to_i, Time.parse(json["created_at"]).to_i
    assert_equal expected_user.updated_at.to_i, Time.parse(json["updated_at"]).to_i
  end
end

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
TestCase.create_database
