class ChangeTimesToFloat < ActiveRecord::Migration
  def up
    change_column :subtitles, :start_time, :float
    change_column :subtitles, :end_time, :float
  end

  def down
    change_column :subtitles, :start_time, :int
    change_column :subtitles, :end_time, :int
  end
end
