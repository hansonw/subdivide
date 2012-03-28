class AddVideoIdToSubtitlesHack < ActiveRecord::Migration
  def up
    add_column :subtitles, :video_id, :integer
  end

  def down
    remove_column :subtitles, :video_id
  end
end
