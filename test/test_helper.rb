require "minitest/autorun"
require "minitest/pride"
require "active_record"
require "oj"
require_relative "../lib/cerealizer"
require_relative "./database"
require_relative "./assert_helpers"
require_relative "./factories"
require_relative "./models/order"
require_relative "./models/user"
require_relative "./models/item"
require_relative "./serializers/item_serializer"
require_relative "./serializers/order_serializer"
require_relative "./serializers/user_serializer"

class TestCase < Minitest::Spec
  include Database
  include AssertHelpers
  include Factories

  before do
    self.class.reset_database
  end
end

TestCase.setup_database
TestCase.create_tables
