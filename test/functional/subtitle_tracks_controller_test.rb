require 'test_helper'

class SubtitleTracksControllerTest < ActionController::TestCase
  setup do
    @subtitle_track = subtitle_tracks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:subtitle_tracks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create subtitle_track" do
    assert_difference('SubtitleTrack.count') do
      post :create, subtitle_track: @subtitle_track.attributes
    end

    assert_redirected_to subtitle_track_path(assigns(:subtitle_track))
  end

  test "should show subtitle_track" do
    get :show, id: @subtitle_track.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @subtitle_track.to_param
    assert_response :success
  end

  test "should update subtitle_track" do
    put :update, id: @subtitle_track.to_param, subtitle_track: @subtitle_track.attributes
    assert_redirected_to subtitle_track_path(assigns(:subtitle_track))
  end

  test "should destroy subtitle_track" do
    assert_difference('SubtitleTrack.count', -1) do
      delete :destroy, id: @subtitle_track.to_param
    end

    assert_redirected_to subtitle_tracks_path
  end
end
