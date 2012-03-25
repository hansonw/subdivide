class AddSubtitleTrackAndTrackSetParents < ActiveRecord::Migration
  def up
    add_column :subtitle_tracks, :subtitle_track_set_id, :integer
    add_column :subtitle_track_sets, :video_id, :integer
  end

  def down
    remove_column :subtitle_track_sets, :video_id
    remove_column :subtitle_tracks, :subtitle_track_set_id
  end
end
