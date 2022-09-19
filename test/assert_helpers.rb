module AssertHelpers
  def assert_user(expected_user, json)
    assert_equal expected_user.id, json["id"]
    assert_equal expected_user.first_name, json["first_name"]
    assert_equal expected_user.last_name, json["last_name"]
    assert_equal "#{expected_user.first_name} #{expected_user.last_name}", json["full_name"]
    assert_equal expected_user.created_at.to_i, Time.parse(json["created_at"]).to_i
    assert_equal expected_user.updated_at.to_i, Time.parse(json["updated_at"]).to_i
  end
end
