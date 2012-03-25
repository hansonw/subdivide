class MoveTimePointsToSubtitles < ActiveRecord::Migration
  def up
    add_column :subtitles, :video_id, :int
    add_column :subtitles, :voice, :int
    add_column :subtitles, :start_time, :int
    add_column :subtitles, :end_time, :int
  end

  def down
    remove_column :subtitles, :video_id
    remove_column :subtitles, :voice
    remove_column :subtitles, :start_time
    remove_column :subtitles, :end_time
  end
end
