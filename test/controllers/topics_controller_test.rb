require "test_helper"

class TopicsControllerTest < ActionDispatch::IntegrationTest
  # Owner tests
  test "owner can edit their own topic" do
    sign_in_as(users(:three))
    topic = topics(:three)

    get edit_topic_path(id: topic.id)
    assert_response :success
  end

  test "owner can update their own topic" do
    sign_in_as(users(:three))
    topic = topics(:three)

    patch topic_path(id: topic.id), params: { topic: { title: "Updated Title" } }
    assert_redirected_to topic_path(id: topic.id)
    follow_redirect!
    assert_response :success
    assert_equal "Updated Title", topic.reload.title
  end

  test "owner can destroy their own topic" do
    sign_in_as(users(:three))
    topic = topics(:three)

    assert_difference("Topic.count", -1) do
      delete topic_path(id: topic.id)
    end
    assert_redirected_to dashboard_path
  end

  # Non-owner tests
  test "non-owner cannot edit topic and gets redirected" do
    sign_in_as(users(:three))
    topic = topics(:one)

    get edit_topic_path(id: topic.id)
    assert_redirected_to dashboard_path
    follow_redirect!
    assert flash[:alert].present?
  end

  test "non-owner cannot update topic and gets redirected" do
    sign_in_as(users(:three))
    topic = topics(:one)

    patch topic_path(id: topic.id), params: { topic: { title: "Hacked Title" } }
    assert_redirected_to dashboard_path
    assert flash[:alert].present?
    assert_not_equal "Hacked Title", topic.reload.title
  end

  test "non-owner cannot destroy topic and gets redirected" do
    sign_in_as(users(:three))
    topic = topics(:one)

    assert_no_difference("Topic.count") do
      delete topic_path(id: topic.id)
    end
    assert_redirected_to dashboard_path
    assert flash[:alert].present?
  end

  # Admin tests
  test "admin cannot edit another user's discussion topic" do
    sign_in_as(users(:one))
    topic = topics(:three)

    get edit_topic_path(id: topic.id)
    assert_redirected_to dashboard_path
    follow_redirect!
    assert flash[:alert].present?
  end

  test "admin cannot update another user's discussion topic" do
    sign_in_as(users(:one))
    topic = topics(:three)

    patch topic_path(id: topic.id), params: { topic: { title: "Admin Updated" } }
    assert_redirected_to dashboard_path
    assert flash[:alert].present?
    assert_not_equal "Admin Updated", topic.reload.title
  end

  test "admin cannot destroy another user's discussion topic" do
    sign_in_as(users(:one))
    topic = topics(:three)

    assert_no_difference("Topic.count") do
      delete topic_path(id: topic.id)
    end
    assert_redirected_to dashboard_path
    assert flash[:alert].present?
  end

  # Cross-condo tests
  test "cross-condo topic access returns 404" do
    sign_in_as(users(:one))
    topic = topics(:two)

    get edit_topic_path(id: topic.id)
    assert_response :not_found
  end

  test "cross-condo topic update returns 404" do
    sign_in_as(users(:one))
    topic = topics(:two)

    patch topic_path(id: topic.id), params: { topic: { title: "Hacked" } }
    assert_response :not_found
  end

  test "cross-condo topic delete returns 404" do
    sign_in_as(users(:one))
    topic = topics(:two)

    delete topic_path(id: topic.id)
    assert_response :not_found
  end

  # Announcement-specific tests
  test "non-admin cannot edit announcement even if they own it" do
    sign_in_as(users(:three))
    topic = topics(:four)

    get edit_topic_path(id: topic.id)
    assert_redirected_to dashboard_path
    follow_redirect!
    assert flash[:alert].present?
  end

  test "admin can edit announcement" do
    sign_in_as(users(:one))
    topic = topics(:four)

    get edit_topic_path(id: topic.id)
    assert_response :success
  end
end
