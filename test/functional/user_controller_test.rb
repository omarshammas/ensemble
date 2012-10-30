require 'test_helper'

class UserControllerTest < ActionController::TestCase
  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

  test "should get logout" do
    get :logout
    assert_response :success
  end

end
