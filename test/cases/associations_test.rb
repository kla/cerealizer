require_relative "../test_helper"

class AssociationsTest < TestCase
  let(:serialized_order) { Serializers::OrderSerializer.new(order).as_json(tags: [ :full ]) }

  it "includes has_many associations" do
    items = serialized_order["items"]
    assert_equal 25, items.length
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

  it "does not include untagged associations" do
    json = Serializers::OrderSerializer.new(order).as_json
    assert_equal false, json.has_key?("items")
    assert_equal false, json["user"].has_key?("full_name")
  end

  it "returns nil for a nil has_one object" do
    order.user = nil
    order.save!
    assert_nil serialized_order["user"]
  end

  it "returns an empty array for an empty has_many association" do
    order.items = []
    order.save!
    assert_equal [], serialized_order["items"]
  end

  it "accepts an exclude_associations option" do
    json = Serializers::OrderSerializer.new(order).as_json(exclude_associations: true)
    assert_equal false, json.has_key?("items")
    assert_equal false, json.has_key?("user")
  end
end
