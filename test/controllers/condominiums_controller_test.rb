require "test_helper"

class CondominiumsControllerTest < ActionDispatch::IntegrationTest
  test "admin can access metrics page" do
    sign_in_as(users(:one))

    get condominium_path(locale: :en)

    assert_response :success
    assert_match "Condo Metrics", response.body
    assert_match "Grand Horizon Towers", response.body
    assert_match "Total Residents", response.body
    assert_match "Admin Announcement", response.body
  end

  test "non-admin is redirected to dashboard" do
    sign_in_as(users(:three))

    get condominium_path

    assert_redirected_to dashboard_path
  end

  test "non-admin is redirected when editing condominium settings" do
    sign_in_as(users(:three))

    get edit_condominium_path

    assert_redirected_to dashboard_path
    follow_redirect!
    assert_response :success
  end

  test "unauthenticated user is redirected to session page" do
    get condominium_path

    assert_redirected_to new_session_path
  end

  test "metrics reflect only current condominium data" do
    sign_in_as(users(:one))

    get condominium_path

    assert_response :success
    assert_match "Plumbing Fix", response.body
    assert_match "Deep Cleaning Service", response.body
    assert_no_match "Electrical Work", response.body
    assert_no_match "Green Valley Residences", response.body
  end

  test "top services are ordered by upvote count" do
    sign_in_as(users(:one))

    service_listings(:three).upvotes.create!(user: users(:one))
    service_listings(:three).upvotes.create!(user: users(:three))
    service_listings(:three).upvotes.create!(user: users(:two))
    service_listings(:one).upvotes.create!(user: users(:three))

    get condominium_path

    assert_response :success

    deep_cleaning_position = response.body.index("Deep Cleaning Service")
    plumbing_position = response.body.index("Plumbing Fix")
    assert deep_cleaning_position < plumbing_position,
      "Expected Deep Cleaning Service (3 vouches) to rank above Plumbing Fix (1 vouch)"
  end
end
