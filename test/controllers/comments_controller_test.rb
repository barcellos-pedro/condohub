require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @topic = topics(:one)
    @comment = comments(:one)
    @author = users(:one)
    @other_user = User.create!(
      condominium: @topic.condominium,
      email_address: "other@example.com",
      password: "password",
      first_name: "Other",
      last_name: "Resident",
      role: :resident
    )
  end

  test "author can edit comment inline" do
    sign_in_as(@author)

    get edit_topic_comment_path(topic_id: @topic, id: @comment), headers: { "Turbo-Frame" => dom_id(@comment) }

    assert_response :success
    assert_select "turbo-frame##{dom_id(@comment)}"
    assert_select "textarea[name='comment[content]']", text: @comment.content
  end

  test "author can update comment" do
    sign_in_as(@author)

    patch topic_comment_path(topic_id: @topic, id: @comment), params: { comment: { content: "Updated comment" } }

    assert_redirected_to topic_path(@topic, anchor: dom_id(@comment))
    assert_equal "Updated comment", @comment.reload.content
  end

  test "blank update keeps validation errors" do
    sign_in_as(@author)

    patch topic_comment_path(topic_id: @topic, id: @comment),
          params: { comment: { content: "" } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :unprocessable_entity
    assert_match "turbo-stream", response.media_type
    assert_not_equal "", @comment.reload.content
  end

  test "author can delete comment" do
    sign_in_as(@author)

    assert_difference("Comment.count", -1) do
      delete topic_comment_path(topic_id: @topic, id: @comment)
    end

    assert_redirected_to topic_path(@topic)
  end

  test "non-author cannot update comment" do
    sign_in_as(@other_user)

    patch topic_comment_path(topic_id: @topic, id: @comment), params: { comment: { content: "Not allowed" } }

    assert_redirected_to topic_path(@topic)
    assert_not_equal "Not allowed", @comment.reload.content
  end

  test "non-author cannot delete comment" do
    sign_in_as(@other_user)

    assert_no_difference("Comment.count") do
      delete topic_comment_path(topic_id: @topic, id: @comment)
    end

    assert_redirected_to topic_path(@topic)
  end

  test "user cannot access comments outside their condominium" do
    sign_in_as(users(:two))

    patch topic_comment_path(topic_id: @topic, id: @comment), params: { comment: { content: "Nope" } }

    assert_response :not_found
  end
end
