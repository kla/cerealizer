require_relative "../test_helper"

class AttributesTest < TestCase
  let(:serializer) { Serializers::UserSerializer.new }

  it "accepts an include_root option" do
    assert_equal user.id, Serializers::UserSerializer.new(include_root: true).as_json(user)["user"]["id"]
    assert_equal user.id, JSON.parse(Serializers::UserSerializer.new(include_root: true).to_json(user))["user"]["id"]
  end

  it "serializes to a hash using as_json" do
    hash = serializer.as_json(user)
    assert_instance_of Hash, hash
    assert_equal user.id, hash["id"]
    assert_equal user.created_at, hash["created_at"]
  end

  it "serializes to a hash with string keys" do
    assert_equal [ String ], Serializers::UserSerializer.new.serializable_hash(user).keys.map(&:class).uniq
  end

  it "serializes to a json string using to_json" do
    json = Serializers::UserSerializer.new.to_json(user)
    assert_instance_of String, json
    assert_user user, JSON.parse(json)
  end

  it "returns nil for a nil object" do
    assert_nil Serializers::UserSerializer.new.as_json(nil)
    assert_equal "null", Serializers::UserSerializer.new.to_json(nil)
  end

  describe "with an :if condition" do
    it "accepts a symbol" do
      refute serializer.as_json(user).has_key?("admin")
      user.update!(permissions: "admin")
      assert Serializers::UserSerializer.new.as_json(user)["admin"]
    end

    it "accepts a proc" do
      refute serializer.as_json(user).has_key?("super_admin")
      user.update!(permissions: "super_admin")
      assert Serializers::UserSerializer.new.as_json(user)["super_admin"]
    end
  end
end
