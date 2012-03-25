class RemoveTimePointIdFromSubtitles < ActiveRecord::Migration
  def up
    remove_column :subtitles, :time_point_id
  end

  def down
    add_column :subtitles, :time_point_id, :int
  end
end
