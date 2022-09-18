require_relative "../test_helper"

class AttributesTest < TestCase
  it "serealizes to a hash using as_json" do
    assert_user user, Serializers::UserSerializer.new(user).as_json
  end

  it "serializes to a hash using to_json" do
    json = Serializers::UserSerializer.new(user).to_json
    assert_instance_of String, json
    assert_user user, JSON.parse(json)
  end

  it "serializes to a hash with symbolized keys using serializable_hash" do
    assert_equal [ Symbol ], Serializers::UserSerializer.new(user).serializable_hash.keys.map(&:class).uniq
  end
end
