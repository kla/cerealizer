require_relative "../test_helper"

class AttributesTest < TestCase
  let(:serializer) { Serializers::UserSerializer }

  it "accepts an include_root option" do
    assert_equal user.id, serializer.serialize_to_hash(user, include_root: true)["user"]["id"]
    assert_equal user.id, JSON.parse(serializer.serialize(user, include_root: true))["user"]["id"]
  end

  it "serializes to a hash using serialize_to_hash" do
    hash = serializer.serialize_to_hash(user)
    assert_instance_of Hash, hash
    assert_equal user.id, hash["id"]
    assert_equal user.created_at, hash["created_at"]
  end

  it "serializes to a hash with string keys" do
    assert_equal [ String ], serializer.serialize_to_hash(user).keys.map(&:class).uniq
  end

  it "serializes to a json string using serialize" do
    json = serializer.serialize(user)
    assert_instance_of String, json
    assert_user user, JSON.parse(json)
  end

  it "returns nil for a nil object" do
    assert_nil serializer.serialize_to_hash(nil)
    assert_equal "null", serializer.serialize(nil)
  end

  it "accepts an except option" do
    hash = serializer.serialize_to_hash(user, except: :full_name)
    assert hash.key?("id")
    refute hash.key?("full_name")

    hash = serializer.serialize_to_hash(user, except: %i[ id full_name ])
    refute hash.key?("id")
    refute hash.key?("full_name")
  end

  it "accepts an only option" do
    hash = serializer.serialize_to_hash(user, only: :full_name)
    assert_equal %w( full_name ), hash.keys

    hash = serializer.serialize_to_hash(user, only: %i[ id full_name ])
    assert_equal %w( id full_name ), hash.keys
  end

  describe "with an :if condition" do
    it "accepts a symbol" do
      refute serializer.serialize_to_hash(user).has_key?("admin")
      user.update!(permissions: "admin")
      assert serializer.serialize_to_hash(user)["admin"]
    end

    it "accepts a proc" do
      refute serializer.serialize_to_hash(user).has_key?("super_admin")
      user.update!(permissions: "super_admin")
      assert serializer.serialize_to_hash(user)["super_admin"]
    end
  end

  describe "association with serialization_options" do
    class TestSerializer < Cerealizer::Base
      attribute :id
      has_one :user, serializer: Serializers::UserSerializer, serialization_options: { only: :first_name }
      has_many :items, serializer: Serializers::ItemSerializer, serialization_options: { only: :order_id }
    end

    it "accepts serialization_options for associations" do
      hash = TestSerializer.serialize_to_hash(order)
      assert_equal %w( id user items), hash.keys
      assert_equal %w( first_name ), hash["user"].keys
      assert_equal %w( order_id ), hash["items"][0].keys
    end
  end

  describe "attribute that returns a hash and array" do
    class AttributeReturnsHashSerializer < Cerealizer::Base
      attribute :data
      attribute :array

      def data
        { a: 1, "b" => 2 }
      end

      def array
        [ { a: 1 } ]
      end
    end

    it "handles keys that are symbols" do
      json = JSON.parse(AttributeReturnsHashSerializer.serialize({}))
      assert_equal %w( a b ), json["data"].keys
      assert_equal 1, json["data"]["a"]
      assert_equal 2, json["data"]["b"]
      assert_equal 1, json["array"][0]["a"]
    end
  end

  describe "serializer with user params" do
    class WithUserParams < Cerealizer::Base
      attribute :admin

      def admin
        params[:admin]
      end
    end

    it "accepts a params option" do
      assert WithUserParams.new(params: { admin: true }).as_json(user)["admin"]
      refute WithUserParams.new(params: { admin: false }).as_json(user)["admin"]
    end
  end
end
