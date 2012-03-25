class AddSubtitleTrackIdToSubtitle < ActiveRecord::Migration
  def up
    add_column :subtitles, :subtitle_track_id, :integer
  end

  def down
    remove_column :subtitles, :subtitle_track_id
  end
end
