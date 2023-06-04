require "test_helper"

class BaseTest < TestCase
  let(:serializer) { Serializers::UserSerializer }
  let(:users) do
    create_user
    create_user
    User.all
  end

  describe "#serialize" do
    it "can serialize an Enumerable" do
      json = JSON.parse(serializer.serialize_enumerable(users))
      assert_equal 2, json.length
      assert json[0]["first_name"]
      assert json[1]["first_name"]
    end
  end
end
