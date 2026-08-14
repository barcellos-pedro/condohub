require "test_helper"

class CondominiumTest < ActiveSupport::TestCase
  test "metrics returns expected keys" do
    metrics = condominiums(:one).metrics
    assert_includes metrics.keys, :total_residents
    assert_includes metrics.keys, :active_residents
    assert_includes metrics.keys, :topics_this_month
    assert_includes metrics.keys, :top_services
    assert_includes metrics.keys, :recent_announcements
  end

  test "metrics are scoped to condominium" do
    metrics = condominiums(:one).metrics
    assert_equal 2, metrics[:total_residents]
  end
end
