require "test_helper"

class WaitlistControllerTest < ActionDispatch::IntegrationTest
  test "create adds a waitlist entry" do
    assert_difference("WaitlistEntry.count") do
      post request_access_path, params: { email_address: "new@example.com" }
    end

    assert_redirected_to root_path
    assert_equal I18n.t("landing.index.request_access_success"), flash[:notice]
  end

  test "create deduplicates an existing email" do
    WaitlistEntry.create!(email_address: "dup@example.com")

    assert_no_difference("WaitlistEntry.count") do
      post request_access_path, params: { email_address: "DUP@example.com" }
    end

    assert_redirected_to root_path
    assert_equal I18n.t("landing.index.request_access_success"), flash[:notice]
  end

  test "create rejects an invalid email" do
    assert_no_difference("WaitlistEntry.count") do
      post request_access_path, params: { email_address: "not-an-email" }
    end

    assert_redirected_to root_path
    assert_equal I18n.t("flash.waitlist.invalid_email"), flash[:alert]
  end

  test "create responds with a turbo stream" do
    post request_access_path, params: { email_address: "stream@example.com", form_id: "request_access_hero" }, as: :turbo_stream

    assert_response :success
    assert_match(/request_access_success/, response.body)
  end
end
