require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "visitor can view registration page with valid token" do
    invitation = invitations(:pending_one)
    get register_url(token: invitation.token)
    assert_response :success
    assert_select "input[value=?]", invitation.email_address
    assert_includes response.body, invitation.condominium.name
  end

  test "visitor redirected when token is invalid" do
    get register_url(token: "nonexistent-token")
    assert_redirected_to new_session_url
    assert_equal I18n.t("flash.registrations.invalid_token"), flash[:alert]
  end

  test "visitor redirected when token is expired" do
    invitation = invitations(:expired_one)
    get register_url(token: invitation.token)
    assert_redirected_to new_session_url
    assert_equal I18n.t("flash.registrations.expired_token"), flash[:alert]
  end

  test "visitor redirected when token is already accepted" do
    invitation = invitations(:accepted_one)
    get register_url(token: invitation.token)
    assert_redirected_to new_session_url
    assert_equal I18n.t("flash.registrations.already_accepted"), flash[:alert]
  end

  test "visitor successfully registers, marks invite accepted, and logs in" do
    invitation = invitations(:pending_one)

    assert_difference -> { User.count } => 1, -> { Session.count } => 1 do
      post register_url(token: invitation.token), params: {
        user: {
          first_name: "John",
          last_name: "Doe",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    new_user = User.find_by(email_address: invitation.email_address)
    assert_not_nil new_user
    assert_equal "John", new_user.first_name
    assert_equal "Doe", new_user.last_name
    assert_equal invitation.condominium, new_user.condominium
    assert new_user.resident?
    assert invitation.reload.accepted?

    assert_redirected_to dashboard_url
    assert cookies["session_id"].present?
  end

  test "registration rejected with invalid params (e.g. password mismatch)" do
    invitation = invitations(:pending_one)

    assert_no_difference [ "User.count", "Session.count" ] do
      post register_url(token: invitation.token), params: {
        user: {
          first_name: "John",
          last_name: "Doe",
          password: "password123",
          password_confirmation: "mismatch"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_not invitation.reload.accepted?
  end

  test "already signed in user is redirected to dashboard" do
    sign_in_as(users(:one))
    invitation = invitations(:pending_one)
    get register_url(token: invitation.token)
    assert_redirected_to dashboard_url
  end
end
