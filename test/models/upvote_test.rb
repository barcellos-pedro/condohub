require "test_helper"

class UpvoteTest < ActiveSupport::TestCase
  test "valid topic upvote" do
    upvote = Upvote.new(user: users(:two), upvotable: topics(:one))
    assert upvote.valid?
  end

  test "valid service listing upvote" do
    upvote = Upvote.new(user: users(:one), upvotable: service_listings(:one))
    assert upvote.valid?
  end

  test "rejects duplicate upvote for same upvotable by same user" do
    Upvote.create!(user: users(:two), upvotable: topics(:one))
    duplicate = Upvote.new(user: users(:two), upvotable: topics(:one))
    assert_not duplicate.valid?
  end

  test "rejects duplicate vouch for same service listing by same user" do
    Upvote.create!(user: users(:one), upvotable: service_listings(:one))
    duplicate = Upvote.new(user: users(:one), upvotable: service_listings(:one))
    assert_not duplicate.valid?
  end

  test "allows same user to upvote a topic and vouch a service listing" do
    Upvote.create!(user: users(:two), upvotable: topics(:one))
    upvote = Upvote.new(user: users(:two), upvotable: service_listings(:one))
    assert upvote.valid?
  end

  test "updates topic upvotes counter cache" do
    topic = topics(:one)
    assert_difference -> { topic.reload.upvotes_count }, 1 do
      Upvote.create!(user: users(:two), upvotable: topic)
    end
  end

  test "updates service listing upvotes counter cache" do
    service_listing = service_listings(:one)
    assert_difference -> { service_listing.reload.upvotes_count }, 1 do
      Upvote.create!(user: users(:two), upvotable: service_listing)
    end
  end
end
