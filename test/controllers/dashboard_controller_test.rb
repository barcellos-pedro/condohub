require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index renders authenticated content" do
    get dashboard_path
    assert_response :success
  end

  test "index hides sandbox persona UI outside development" do
    get dashboard_path
    assert_response :success
    assert_no_match(/Sandbox Mode/i, response.body)
    assert_no_match(/Switch Persona/i, response.body)
  end
end
