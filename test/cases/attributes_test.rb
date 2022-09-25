require_relative "../test_helper"

class AttributesTest < TestCase
  let(:serializer) { Serializers::UserSerializer.new(user) }

  it "serializes to a hash and json" do
    assert_equal serializer.to_json(tags: [ :full ]), JSON.generate(serializer.as_json(tags: [ :full ]))
  end

  it "serializes to a hash using as_json" do
    assert_user user, serializer.as_json(tags: [ :full ])
  end

  it "serializes to a hash using to_json" do
    json = Serializers::UserSerializer.new(user).to_json(tags: [ :full ])
    assert_instance_of String, json
    assert_user user, JSON.parse(json)
  end

  # it "serializes to a hash with symbolized keys using serializable_hash" do
  #   assert_equal [ Symbol ], Serializers::UserSerializer.new(user).serializable_hash.keys.map(&:class).uniq
  # end

  it "does not include untagged attributes" do
    assert_equal false, serializer.as_json.has_key?("full_name")
  end

  # it "returns nil for a nil object" do
  #   assert_nil Serializers::UserSerializer.new(nil).as_json
  # end

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

  it "writes as_json" do
    puts "as_json: #{serializer.as_json(tags: [ :full ])}"
    puts "to_json: #{serializer.to_json(tags: [ :full ])}"
  end
end
