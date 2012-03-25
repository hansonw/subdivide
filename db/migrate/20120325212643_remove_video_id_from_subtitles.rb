class RemoveVideoIdFromSubtitles < ActiveRecord::Migration
  def up
    remove_column :subtitles, :video_id
  end

  def down
    add_column :subtitles, :video_id, :integer
  end
end
