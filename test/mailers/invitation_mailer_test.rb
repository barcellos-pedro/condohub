require "test_helper"

class InvitationMailerTest < ActionMailer::TestCase
  test "invite mailer delivers email with token URL" do
    invitation = invitations(:pending_one)
    mail = InvitationMailer.invite(invitation)

    assert_emails 1 do
      mail.deliver_now
    end

    assert_equal [ invitation.email_address ], mail.to
    assert_includes mail.subject, invitation.condominium.name
    assert_includes mail.body.encoded, invitation.token
    assert_includes mail.body.encoded, invitation.condominium.name
  end
end
