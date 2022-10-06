module AssertHelpers
  def assert_user(expected_user, json)
    assert_equal expected_user.id, json["id"]
    assert_equal expected_user.first_name, json["first_name"]
    assert_equal expected_user.last_name, json["last_name"]
    assert_equal "#{expected_user.first_name} #{expected_user.last_name}", json["full_name"]

    created_at = (json["created_at"].is_a?(String) ? Time.parse(json["created_at"])  : json["created_at"]).to_i
    updated_at = (json["updated_at"].is_a?(String) ? Time.parse(json["created_at"]) : json["updated_at"]).to_i
    assert_equal expected_user.created_at.to_i, created_at
    assert_equal expected_user.updated_at.to_i, updated_at
  end
end
