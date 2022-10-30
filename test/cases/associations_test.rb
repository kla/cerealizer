require_relative "../test_helper"

class AssociationsTest < TestCase
  let(:serializer) { Serializers::OrderSerializer }

  def self.serialization_tests
    it "includes has_many associations" do
      items = serialized_order["items"]
      assert_equal 25, items.length
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

  describe "with user params" do
    class OneSerializer < Cerealizer::Base
      attribute :admin, method: :admin

      def admin
        params[:admin]
      end
    end

    class ManySerializer < Cerealizer::Base
      attribute :admin, method: :admin

      def admin
        params[:admin]
      end
    end

    class WithUserParamsSerializer < Cerealizer::Base
      attribute :admin, method: :admin
      has_one :one, method: :one, serializer: OneSerializer
      has_many :many, method: :many, serializer: ManySerializer

      def admin
        params[:admin]
      end

      def one
        object
      end

      def many
        [ object ]
      end
    end

    it "passes params to associations" do
      json = WithUserParamsSerializer.new(params: { admin: 1 }).as_json({})
      assert_equal 1, json["admin"]
      assert_equal 1, json["one"]["admin"]
      assert_equal 1, json["many"][0]["admin"]
    end
  end
end
