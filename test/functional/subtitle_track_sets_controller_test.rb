require 'test_helper'

class SubtitleTrackSetsControllerTest < ActionController::TestCase
  setup do
    @subtitle_track_set = subtitle_track_sets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:subtitle_track_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create subtitle_track_set" do
    assert_difference('SubtitleTrackSet.count') do
      post :create, subtitle_track_set: @subtitle_track_set.attributes
    end

    assert_redirected_to subtitle_track_set_path(assigns(:subtitle_track_set))
  end

  test "should show subtitle_track_set" do
    get :show, id: @subtitle_track_set.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @subtitle_track_set.to_param
    assert_response :success
  end

  test "should update subtitle_track_set" do
    put :update, id: @subtitle_track_set.to_param, subtitle_track_set: @subtitle_track_set.attributes
    assert_redirected_to subtitle_track_set_path(assigns(:subtitle_track_set))
  end

  test "should destroy subtitle_track_set" do
    assert_difference('SubtitleTrackSet.count', -1) do
      delete :destroy, id: @subtitle_track_set.to_param
    end

    assert_redirected_to subtitle_track_sets_path
  end
end
