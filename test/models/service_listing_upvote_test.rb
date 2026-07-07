require "test_helper"

class ServiceListingUpvoteTest < ActiveSupport::TestCase
  test "valid with user and service listing" do
    service_listing_upvote = ServiceListingUpvote.new(user: users(:one), service_listing: service_listings(:one))

    assert service_listing_upvote.valid?
  end

  test "rejects duplicate vouches for the same service listing by the same user" do
    ServiceListingUpvote.create!(user: users(:one), service_listing: service_listings(:one))
    duplicate = ServiceListingUpvote.new(user: users(:one), service_listing: service_listings(:one))

    assert_not duplicate.valid?
  end

  test "updates service listing upvotes count" do
    service_listing = service_listings(:one)

    assert_difference -> { service_listing.reload.upvotes_count }, 1 do
      ServiceListingUpvote.create!(user: users(:one), service_listing:)
    end
  end
end
