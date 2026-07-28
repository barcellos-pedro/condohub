require "test_helper"

class ResidentsControllerTest < ActionDispatch::IntegrationTest
  test "should show resident profile" do
    sign_in_as(users(:one))
    get resident_path(id: users(:three).id)
    assert_response :success
    assert_select "h1", text: users(:three).full_name
  end

  test "should show resident contributions" do
    sign_in_as(users(:one))
    get resident_path(id: users(:three).id)
    assert_response :success
    assert_select "div[style*='text-align: center']", minimum: 4
  end

  test "should redirect when resident not found" do
    sign_in_as(users(:one))
    get resident_path(id: 999999)
    assert_redirected_to dashboard_path
    follow_redirect!
    assert flash[:alert].present?
  end

  test "should redirect when resident from different condominium" do
    sign_in_as(users(:one))
    get resident_path(id: users(:two).id)
    assert_redirected_to dashboard_path
    follow_redirect!
    assert flash[:alert].present?
  end

  test "should require authentication" do
    get resident_path(id: users(:one).id)
    assert_redirected_to new_session_path
  end
end
