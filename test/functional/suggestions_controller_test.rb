require 'test_helper'

class SuggestionsControllerTest < ActionController::TestCase
  setup do
    @suggestion = suggestions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:suggestions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create suggestion" do
    assert_difference('Suggestion.count') do
      post :create, suggestion: { acceptance_status: @suggestion.acceptance_status, body: @suggestion.body, interation_id: @suggestion.interation_id, task_id: @suggestion.task_id, user_id: @suggestion.user_id, vote_count: @suggestion.vote_count, vote_status: @suggestion.vote_status }
    end

    assert_redirected_to suggestion_path(assigns(:suggestion))
  end

  test "should show suggestion" do
    get :show, id: @suggestion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @suggestion
    assert_response :success
  end

  test "should update suggestion" do
    put :update, id: @suggestion, suggestion: { acceptance_status: @suggestion.acceptance_status, body: @suggestion.body, interation_id: @suggestion.interation_id, task_id: @suggestion.task_id, user_id: @suggestion.user_id, vote_count: @suggestion.vote_count, vote_status: @suggestion.vote_status }
    assert_redirected_to suggestion_path(assigns(:suggestion))
  end

  test "should destroy suggestion" do
    assert_difference('Suggestion.count', -1) do
      delete :destroy, id: @suggestion
    end

    assert_redirected_to suggestions_path
  end
end
