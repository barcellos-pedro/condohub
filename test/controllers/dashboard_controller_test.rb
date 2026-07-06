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

  test "redirects unauthenticated requests to the matching locale session page" do
    sign_out

    get dashboard_path(locale: :"pt-BR")

    assert_redirected_to new_session_path(locale: :"pt-BR")
  end
end
