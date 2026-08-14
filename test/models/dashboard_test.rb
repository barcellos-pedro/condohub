require "test_helper"

class DashboardTest < ActiveSupport::TestCase
  test "query returns discussions by default" do
    result = Dashboard.query(condominium: condominiums(:one))
    assert_equal "discussions", result.tab
    assert result.items.any?
  end

  test "query returns announcements when tab is announcements" do
    result = Dashboard.query(condominium: condominiums(:one), tab: "announcements")
    assert_equal "announcements", result.tab
  end

  test "query returns services when tab is services" do
    result = Dashboard.query(condominium: condominiums(:one), tab: "services")
    assert_equal "services", result.tab
  end

  test "query filters by search term" do
    result = Dashboard.query(condominium: condominiums(:one), search: "Resident Discussion")
    assert result.items.any? { |t| t.title == "Resident Discussion" }
  end

  test "query filters services by category" do
    result = Dashboard.query(condominium: condominiums(:one), tab: "services", category: "cleaning")
    assert result.items.all? { |s| s.category == "cleaning" }
  end

  test "query respects pagination" do
    21.times do |i|
      Topic.create!(
        condominium: condominiums(:one),
        user: users(:one),
        title: "Pagination #{i}",
        content: "Content #{i}",
        topic_type: :discussion
      )
    end
    result = Dashboard.query(condominium: condominiums(:one), page: 0, per_page: 20)
    assert_equal 20, result.items.size
    assert result.has_more
  end

  test "query scopes to condominium" do
    result = Dashboard.query(condominium: condominiums(:one))
    assert result.items.all? { |t| t.condominium_id == condominiums(:one).id }
  end
end
