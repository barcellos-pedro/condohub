require "test_helper"

class ServiceListingsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "vouch creates one service listing upvote" do
    service_listing = service_listings(:one)

    assert_difference -> { ServiceListingUpvote.count }, 1 do
      assert_difference -> { service_listing.reload.upvotes_count }, 1 do
        post vouch_service_listing_path(id: service_listing.id)
      end
    end

    assert_redirected_to dashboard_path(tab: "services")
  end

  test "vouch removes existing service listing upvote" do
    service_listing = service_listings(:one)
    ServiceListingUpvote.create!(user: users(:one), service_listing:)

    assert_difference -> { ServiceListingUpvote.count }, -1 do
      assert_difference -> { service_listing.reload.upvotes_count }, -1 do
        post vouch_service_listing_path(id: service_listing.id)
      end
    end

    assert_redirected_to dashboard_path(tab: "services")
  end

  test "vouch cannot access service listings from another condominium" do
    assert_no_difference -> { ServiceListingUpvote.count } do
      post vouch_service_listing_path(id: service_listings(:two).id)
    end

    assert_response :not_found
  end
end
