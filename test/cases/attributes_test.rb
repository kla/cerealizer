require_relative "../test_helper"

class AttributesTest < TestCase
  let(:serializer) { Serializers::UserSerializer.new(user) }

  it "serealizes to a hash using as_json" do
    assert_user user, serializer.as_json(tags: [ :full ])
  end

  it "serializes to a hash using to_json" do
    json = Serializers::UserSerializer.new(user).to_json(tags: [ :full ])
    assert_instance_of String, json
    assert_user user, JSON.parse(json)
  end

  it "serializes to a hash with symbolized keys using serializable_hash" do
    assert_equal [ Symbol ], Serializers::UserSerializer.new(user).serializable_hash.keys.map(&:class).uniq
  end

  it "does not include untagged attributes" do
    assert_equal false, serializer.as_json.has_key?("full_name")
  end

  it "returns nil for a nil object" do
    assert_nil Serializers::UserSerializer.new(nil).as_json
  end
end
