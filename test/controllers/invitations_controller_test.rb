require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  test "admin can view new invitation page" do
    sign_in_as(users(:one))
    get new_invitation_url
    assert_response :success
  end

  test "resident cannot view new invitation page" do
    sign_in_as(users(:three))
    get new_invitation_url
    assert_redirected_to dashboard_url
    assert_equal I18n.t("condominiums.unauthorized"), flash[:alert]
  end

  test "unauthenticated user is redirected to sign in" do
    get new_invitation_url
    assert_redirected_to new_session_url
  end

  test "admin can create invitation and email is enqueued" do
    sign_in_as(users(:one))

    assert_emails 1 do
      post invitations_url, params: {
        invitation: {
          email_address: "brandnew@example.com"
        }
      }
    end

    invitation = Invitation.find_by(email_address: "brandnew@example.com")
    assert_not_nil invitation
    assert_equal users(:one).condominium, invitation.condominium
    assert_equal users(:one), invitation.invited_by
    assert_redirected_to invitation_path(id: invitation.id)
  end

  test "fails when email is already registered" do
    sign_in_as(users(:one))

    assert_no_emails do
      post invitations_url, params: {
        invitation: {
          email_address: users(:three).email_address
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "admin can view show page of invitation in their condo" do
    sign_in_as(users(:one))
    get invitation_path(id: invitations(:pending_one).id)
    assert_response :success
  end

  test "admin cannot view invitation from another condominium" do
    # users(:one) belongs to condominium(:one)
    # let's create an invitation in condominium(:two)
    other_condo_invite = Invitation.create!(
      condominium: condominiums(:two),
      invited_by: users(:two),
      email_address: "other_condo_guest@example.com"
    )

    sign_in_as(users(:one))
    get invitation_path(id: other_condo_invite.id)
    assert_response :not_found
  end
end
