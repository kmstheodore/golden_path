require "test_helper"

class PathsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get paths_index_url
    assert_response :success
  end

  test "should get new" do
    get paths_new_url
    assert_response :success
  end

  test "should get create" do
    get paths_create_url
    assert_response :success
  end
end
