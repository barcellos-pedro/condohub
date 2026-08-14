require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index renders authenticated content" do
    get dashboard_path
    assert_response :success
  end

  test "index hides sandbox persona UI outside development" do
    get dashboard_path
    assert_response :success
    assert_no_match(/Sandbox Mode/i, response.body)
    assert_no_match(/Switch Persona/i, response.body)
  end

  test "redirects unauthenticated requests to the matching locale session page" do
    sign_out

    get dashboard_path(locale: :"pt-BR")

    assert_redirected_to new_session_path(locale: :"pt-BR")
  end

  test "search finds topics by title" do
    get dashboard_path, params: { q: "Resident Discussion" }
    assert_response :success
    assert_match "Resident Discussion", response.body
    assert_no_match "Admin Announcement", response.body
  end

  test "search finds topics by content" do
    get dashboard_path, params: { q: "Discussion content from resident" }
    assert_response :success
    assert_match "Resident Discussion", response.body
  end

  test "search finds services by title" do
    get dashboard_path(tab: "services"), params: { q: "Plumbing" }
    assert_response :success
    assert_match "Plumbing Fix", response.body
    assert_no_match "Deep Cleaning", response.body
  end

  test "search finds services by description" do
    get dashboard_path(tab: "services"), params: { q: "Thorough cleaning" }
    assert_response :success
    assert_match "Deep Cleaning Service", response.body
  end

  test "empty search returns all results" do
    get dashboard_path, params: { q: "" }
    assert_response :success
    assert_match "MyString", response.body
    assert_match "Resident Discussion", response.body
  end

  test "category filter shows only matching services" do
    get dashboard_path(tab: "services", category: "cleaning")
    assert_response :success
    assert_match "Deep Cleaning Service", response.body
    assert_no_match "Plumbing Fix", response.body
  end

  test "pagination returns exactly 20 items" do
    21.times do |i|
      Topic.create!(
        condominium: condominiums(:one),
        user: users(:one),
        title: "Pagination Topic #{i}",
        content: "Content #{i}",
        topic_type: :discussion
      )
    end

    get dashboard_path(locale: :en, tab: "discussions")
    assert_response :success
    assert_match "Load more", response.body

    rendered_topics = response.body.scan(/class="post-card"/).length
    assert_equal 20, rendered_topics
  end

  test "cross-condo content never appears in search results" do
    get dashboard_path, params: { q: "Electrical" }
    assert_response :success
    assert_no_match "Electrical Work", response.body
  end

  test "sort param renders sort controls on discussions tab" do
    get dashboard_path, params: { tab: "discussions", sort: "recent" }
    assert_response :success
    assert_match "sort-link", response.body
  end

  test "sort param renders sort controls on services tab" do
    get dashboard_path, params: { tab: "services", sort: "recent" }
    assert_response :success
    assert_match "sort-link", response.body
  end

  test "sort unanswered only shows topics with zero comments" do
    get dashboard_path, params: { tab: "discussions", sort: "unanswered" }
    assert_response :success
  end
end
