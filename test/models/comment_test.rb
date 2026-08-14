require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "owner can edit" do
    assert comments(:one).editable_by?(users(:one))
  end

  test "non-owner cannot edit" do
    assert_not comments(:one).editable_by?(users(:three))
  end

  test "nil user cannot edit" do
    assert_not comments(:one).editable_by?(nil)
  end
end
