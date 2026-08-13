require "test_helper"

class UpvotesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "upvotes a topic" do
    topic = topics(:one)

    assert_difference -> { Upvote.where(upvotable: topic).count }, 1 do
      assert_difference -> { topic.reload.upvotes_count }, 1 do
        post topic_upvote_path(topic_id: topic.id)
      end
    end

    assert_redirected_to dashboard_path
  end

  test "removes upvote from a topic" do
    topic = topics(:one)
    Upvote.create!(user: users(:one), upvotable: topic)

    assert_difference -> { Upvote.where(upvotable: topic).count }, -1 do
      assert_difference -> { topic.reload.upvotes_count }, -1 do
        post topic_upvote_path(topic_id: topic.id)
      end
    end

    assert_redirected_to dashboard_path
  end

  test "vouches for a service listing" do
    service_listing = service_listings(:one)

    assert_difference -> { Upvote.where(upvotable: service_listing).count }, 1 do
      assert_difference -> { service_listing.reload.upvotes_count }, 1 do
        post service_listing_upvote_path(service_listing_id: service_listing.id)
      end
    end

    assert_redirected_to dashboard_path(tab: "services")
  end

  test "removes vouch from a service listing" do
    service_listing = service_listings(:one)
    Upvote.create!(user: users(:one), upvotable: service_listing)

    assert_difference -> { Upvote.where(upvotable: service_listing).count }, -1 do
      assert_difference -> { service_listing.reload.upvotes_count }, -1 do
        post service_listing_upvote_path(service_listing_id: service_listing.id)
      end
    end

    assert_redirected_to dashboard_path(tab: "services")
  end

  test "cannot upvote a topic from another condominium" do
    assert_no_difference -> { Upvote.count } do
      post topic_upvote_path(topic_id: topics(:two).id)
    end

    assert_response :not_found
  end

  test "upvotes a comment" do
    comment = comments(:one)

    assert_difference -> { Upvote.where(upvotable: comment).count }, 1 do
      assert_difference -> { comment.reload.upvotes_count }, 1 do
        post topic_comment_upvote_path(topic_id: comment.topic_id, comment_id: comment.id)
      end
    end

    assert_redirected_to topic_path(comment.topic, anchor: dom_id(comment))
  end

  test "removes upvote from a comment" do
    comment = comments(:one)
    Upvote.create!(user: users(:one), upvotable: comment)

    assert_difference -> { Upvote.where(upvotable: comment).count }, -1 do
      assert_difference -> { comment.reload.upvotes_count }, -1 do
        post topic_comment_upvote_path(topic_id: comment.topic_id, comment_id: comment.id)
      end
    end

    assert_redirected_to topic_path(comment.topic, anchor: dom_id(comment))
  end

  test "cannot upvote a comment from another condominium" do
    assert_no_difference -> { Upvote.count } do
      post topic_comment_upvote_path(topic_id: topics(:two).id, comment_id: comments(:two).id)
    end

    assert_response :not_found
  end
end
