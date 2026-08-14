require "test_helper"

class WaitlistEntryTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    entry = WaitlistEntry.new(email_address: " SOMEONE@EXAMPLE.COM ")
    assert_equal "someone@example.com", entry.email_address
  end

  test "valid with a well-formed email" do
    entry = WaitlistEntry.new(email_address: "someone@example.com")
    assert entry.valid?
  end

  test "invalid without a well-formed email" do
    entry = WaitlistEntry.new(email_address: "not-an-email")
    assert_not entry.valid?
  end

  test "requires unique email regardless of case" do
    WaitlistEntry.create!(email_address: "dup@example.com")
    dup = WaitlistEntry.new(email_address: "DUP@example.com")
    assert_not dup.valid?
  end
end
