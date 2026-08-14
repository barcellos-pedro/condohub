require "test_helper"

class TopicTest < ActiveSupport::TestCase
  test "owner can edit their discussion" do
    assert topics(:three).editable_by?(users(:three))
  end

  test "non-owner cannot edit discussion" do
    assert_not topics(:three).editable_by?(users(:one))
  end

  test "admin can edit announcement" do
    assert topics(:four).editable_by?(users(:one))
  end

  test "non-admin cannot edit announcement even if they own it" do
    assert_not topics(:four).editable_by?(users(:three))
  end

  test "nil user cannot edit" do
    assert_not topics(:one).editable_by?(nil)
  end
end
