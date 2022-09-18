require_relative "../test_helper"

class AssociationsTest < TestCase
  let(:serialized_order) { Serializers::OrderSerializer.new(order).as_json }

  it "includes has_many associations" do
    items = serialized_order["items"]
    assert_equal 2, items.length
    assert_equal "Item 1", items[0]["name"]
    assert_equal "Item 2", items[1]["name"]
    assert_equal "10.0", items[0]["price"]
    assert_equal "20.0", items[1]["price"]
    assert_equal order.id, items[0]["order_id"]
    assert_equal order.id, items[1]["order_id"]
    assert_equal 1, items[0]["quantity"]
    assert_equal 2, items[1]["quantity"]
    assert_equal order.items[0].id, items[0]["id"]
    assert_equal order.items[1].id, items[1]["id"]
  end

  it "includes has_one associations" do
    assert_user user, serialized_order["user"]
  end
end
