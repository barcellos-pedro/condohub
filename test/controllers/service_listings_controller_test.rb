require "test_helper"

class ServiceListingsControllerTest < ActionDispatch::IntegrationTest
  # Owner tests
  test "owner can edit their own service listing" do
    sign_in_as(users(:three))
    service = service_listings(:three)

    get edit_service_listing_path(id: service.id)
    assert_response :success
  end

  test "owner can update their own service listing" do
    sign_in_as(users(:three))
    service = service_listings(:three)

    patch service_listing_path(id: service.id), params: { service_listing: { title: "Updated Service" } }
    assert_redirected_to dashboard_path(tab: "services")
    assert_equal "Updated Service", service.reload.title
  end

  test "owner can destroy their own service listing" do
    sign_in_as(users(:three))
    service = service_listings(:three)

    assert_difference("ServiceListing.count", -1) do
      delete service_listing_path(id: service.id)
    end
    assert_redirected_to dashboard_path(tab: "services")
  end

  # Non-owner tests
  test "non-owner cannot edit service listing and gets redirected" do
    sign_in_as(users(:three))
    service = service_listings(:one)

    get edit_service_listing_path(id: service.id)
    assert_redirected_to dashboard_path(tab: "services")
    follow_redirect!
    assert flash[:alert].present?
  end

  test "non-owner cannot update service listing and gets redirected" do
    sign_in_as(users(:three))
    service = service_listings(:one)

    patch service_listing_path(id: service.id), params: { service_listing: { title: "Hacked" } }
    assert_redirected_to dashboard_path(tab: "services")
    assert flash[:alert].present?
    assert_not_equal "Hacked", service.reload.title
  end

  test "non-owner cannot destroy service listing and gets redirected" do
    sign_in_as(users(:three))
    service = service_listings(:one)

    assert_no_difference("ServiceListing.count") do
      delete service_listing_path(id: service.id)
    end
    assert_redirected_to dashboard_path(tab: "services")
    assert flash[:alert].present?
  end

  # Admin tests
  test "admin can edit any service listing in their condominium" do
    sign_in_as(users(:one))
    service = service_listings(:three)

    get edit_service_listing_path(id: service.id)
    assert_response :success
  end

  test "admin can update any service listing in their condominium" do
    sign_in_as(users(:one))
    service = service_listings(:three)

    patch service_listing_path(id: service.id), params: { service_listing: { title: "Admin Updated" } }
    assert_redirected_to dashboard_path(tab: "services")
    assert_equal "Admin Updated", service.reload.title
  end

  test "admin can destroy any service listing in their condominium" do
    sign_in_as(users(:one))
    service = service_listings(:three)

    assert_difference("ServiceListing.count", -1) do
      delete service_listing_path(id: service.id)
    end
    assert_redirected_to dashboard_path(tab: "services")
  end

  # Cross-condo tests
  test "cross-condo service listing access returns 404" do
    sign_in_as(users(:one))
    service = service_listings(:two)

    get edit_service_listing_path(id: service.id)
    assert_response :not_found
  end

  test "cross-condo service listing update returns 404" do
    sign_in_as(users(:one))
    service = service_listings(:two)

    patch service_listing_path(id: service.id), params: { service_listing: { title: "Hacked" } }
    assert_response :not_found
  end

  test "cross-condo service listing delete returns 404" do
    sign_in_as(users(:one))
    service = service_listings(:two)

    delete service_listing_path(id: service.id)
    assert_response :not_found
  end

  # Existing vouch tests
  test "vouch creates one service listing upvote" do
    sign_in_as(users(:one))
    service_listing = service_listings(:one)

    assert_difference -> { Upvote.where(upvotable: service_listing).count }, 1 do
      assert_difference -> { service_listing.reload.upvotes_count }, 1 do
        post service_listing_upvote_path(service_listing_id: service_listing.id)
      end
    end

    assert_redirected_to dashboard_path(tab: "services")
  end

  test "vouch removes existing service listing upvote" do
    sign_in_as(users(:one))
    service_listing = service_listings(:one)
    Upvote.create!(user: users(:one), upvotable: service_listing)

    assert_difference -> { Upvote.where(upvotable: service_listing).count }, -1 do
      assert_difference -> { service_listing.reload.upvotes_count }, -1 do
        post service_listing_upvote_path(service_listing_id: service_listing.id)
      end
    end

    assert_redirected_to dashboard_path(tab: "services")
  end

  test "vouch cannot access service listings from another condominium" do
    sign_in_as(users(:one))
    assert_no_difference -> { Upvote.count } do
      post service_listing_upvote_path(service_listing_id: service_listings(:two).id)
    end

    assert_response :not_found
  end
end
