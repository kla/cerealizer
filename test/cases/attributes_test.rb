require_relative "../test_helper"

class AttributesTest < TestCase
  let(:serializer) { Serializers::UserSerializer.new(user) }

  it "accepts an include_root option" do
    assert_equal user.id, serializer.as_json(include_root: true)["user"]["id"]
    assert_equal user.id, JSON.parse(serializer.to_json(include_root: true))["user"]["id"]
  end

  it "serializes to a hash using as_json" do
    hash = serializer.as_json(tags: [ :full ])
    assert_instance_of Hash, hash
    assert_equal user.id, hash["id"]
    assert_equal user.created_at, hash["created_at"]
  end

  it "serializes to a hash with string keys" do
    assert_equal [ String ], Serializers::UserSerializer.new(user).serializable_hash.keys.map(&:class).uniq
  end

  it "serializes to a json string using to_json" do
    json = Serializers::UserSerializer.new(user).to_json(tags: [ :full ])
    assert_instance_of String, json
    assert_user user, JSON.parse(json)
  end

  it "does not include untagged attributes" do
    assert_equal false, serializer.as_json.has_key?("full_name")
  end

  it "returns nil for a nil object" do
    assert_nil Serializers::UserSerializer.new(nil).as_json
    assert_equal "null", Serializers::UserSerializer.new(nil).to_json
  end

  describe "with an :if condition" do
    it "accepts a symbol" do
      refute serializer.as_json.has_key?("admin")
      user.update!(permissions: "admin")
      assert Serializers::UserSerializer.new(user).as_json["admin"]
    end

    it "accepts a proc" do
      refute serializer.as_json.has_key?("super_admin")
      user.update!(permissions: "super_admin")
      assert Serializers::UserSerializer.new(user).as_json["super_admin"]
    end
  end
end
