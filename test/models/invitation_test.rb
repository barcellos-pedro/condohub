require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  test "valid invitation" do
    invitation = Invitation.new(
      condominium: condominiums(:one),
      invited_by: users(:one),
      email_address: "newresident@example.com"
    )
    assert invitation.valid?
    assert invitation.save
    assert invitation.token.present?
    assert invitation.expires_at.present?
    assert invitation.pending?
    assert_not invitation.expired?
    assert_not invitation.accepted?
  end

  test "invalid without email_address" do
    invitation = Invitation.new(
      condominium: condominiums(:one),
      invited_by: users(:one),
      email_address: nil
    )
    assert_not invitation.valid?
    assert invitation.errors[:email_address].any?
  end

  test "invalid with malformed email_address" do
    invitation = Invitation.new(
      condominium: condominiums(:one),
      invited_by: users(:one),
      email_address: "not-an-email"
    )
    assert_not invitation.valid?
    assert invitation.errors[:email_address].any?
  end

  test "invalid when email is already registered to an existing user" do
    invitation = Invitation.new(
      condominium: condominiums(:one),
      invited_by: users(:one),
      email_address: users(:one).email_address
    )
    assert_not invitation.valid?
    assert invitation.errors[:email_address].any?
  end

  test "normalizes email address" do
    invitation = Invitation.create!(
      condominium: condominiums(:one),
      invited_by: users(:one),
      email_address: "  CAPS_USER@Example.COM  "
    )
    assert_equal "caps_user@example.com", invitation.email_address
  end

  test "accept! updates accepted_at" do
    invitation = invitations(:pending_one)
    assert_not invitation.accepted?
    assert invitation.accept!
    assert invitation.accepted?
    assert_not invitation.pending?
  end

  test "expired? returns true when expires_at in the past" do
    invitation = invitations(:expired_one)
    assert invitation.expired?
    assert_not invitation.pending?
  end
end
