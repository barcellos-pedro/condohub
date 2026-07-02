require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should render 404 not found page" do
    get "/errors/404"
    assert_response :not_found
    assert_match(/404/, response.body)
    assert_match(/couldn't find the page/, response.body)
  end

  test "should render 500 internal server error page" do
    get "/errors/500"
    assert_response :internal_server_error
    assert_match(/500/, response.body)
    assert_match(/Something went wrong/, response.body)
  end

  test "should render 422 unprocessable entity page" do
    get "/errors/422"
    assert_response :unprocessable_entity
    assert_match(/422/, response.body)
    assert_match(/couldn't be processed/, response.body)
  end

  test "accessing a nonexistent route should render the custom 404 page" do
    get "/nonexistent-path-that-does-not-exist"
    assert_response :not_found
    assert_match(/404/, response.body)
    assert_match(/couldn't find the page/, response.body)
  end
end
