require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    sign_in_as(users(:one))
    get edit_profile_path
    assert_response :success
  end

  test "should update profile with valid data" do
    sign_in_as(users(:one))
    patch profile_path, params: { user: { first_name: "Updated", last_name: "Name", email_address: "updated@example.com" } }
    assert_redirected_to edit_profile_path
    follow_redirect!
    assert_response :success
    assert_equal "Updated", users(:one).reload.first_name
  end

  test "should not update profile with duplicate email" do
    sign_in_as(users(:one))
    patch profile_path, params: { user: { email_address: users(:three).email_address } }
    assert_response :unprocessable_entity
  end

  test "should not update profile with invalid email format" do
    sign_in_as(users(:one))
    patch profile_path, params: { user: { email_address: "invalid-email" } }
    assert_response :unprocessable_entity
  end

  test "should update password with correct current password" do
    sign_in_as(users(:one))
    patch profile_path, params: { user: { current_password: "password", password: "newpassword", password_confirmation: "newpassword" } }
    assert_redirected_to edit_profile_path
    follow_redirect!
    assert_response :success
  end

  test "should not update password with wrong current password" do
    sign_in_as(users(:one))
    patch profile_path, params: { user: { current_password: "wrongpassword", password: "newpassword", password_confirmation: "newpassword" } }
    assert_response :unprocessable_entity
    assert flash.now[:alert].present?
  end

  test "should require authentication" do
    get edit_profile_path
    assert_redirected_to new_session_path
  end
end
