require "test_helper"

class ServiceListingTest < ActiveSupport::TestCase
  test "owner can edit" do
    assert service_listings(:one).editable_by?(users(:one))
  end

  test "admin can edit" do
    assert service_listings(:three).editable_by?(users(:one))
  end

  test "non-owner non-admin cannot edit" do
    assert_not service_listings(:one).editable_by?(users(:three))
  end

  test "nil user cannot edit" do
    assert_not service_listings(:one).editable_by?(nil)
  end
end
