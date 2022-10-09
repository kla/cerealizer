require_relative "../test_helper"

class AssociationsTest < TestCase
  let(:serializer) { Serializers::OrderSerializer }

  def self.serialization_tests
    it "includes has_many associations" do
      items = serialized_order["items"]
      assert_equal 2, items.length
      assert_equal "Item 1", items[0]["name"]
      assert_equal "Item 2", items[1]["name"]
      assert_equal "10.0", items[0]["price"].to_s
      assert_equal "20.0", items[1]["price"].to_s
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
  end

  describe "serializing to a json string" do
    let(:serialized_order) { JSON.parse(serializer.serialize(order)) }
    serialization_tests
  end

  describe "serializing to a hash" do
    let(:serialized_order) { serializer.serialize_to_hash(order) }
    serialization_tests
  end

  it "accepts an exclude_associations option" do
    json = serializer.serialize_to_hash(order, exclude_associations: true)
    assert_equal false, json.has_key?("items")
    assert_equal false, json.has_key?("user")
  end
end
