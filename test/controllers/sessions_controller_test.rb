require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "new hides impersonation UI outside development" do
    get new_session_path

    assert_response :success
    assert_no_match(/Developer Sandbox/i, response.body)
  end

  test "impersonate is blocked outside development" do
    assert_no_difference("Session.count") do
      post impersonate_session_path(user_id: @user.id)
    end

    assert_redirected_to new_session_path
    assert_equal "Impersonation is only available in local development.", flash[:alert]
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
