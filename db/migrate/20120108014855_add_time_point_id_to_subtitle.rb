class AddTimePointIdToSubtitle < ActiveRecord::Migration
  def up
    add_column :subtitles, :time_point_id, :integer
  end
  def down
    remove_column :subtitles, :time_point_id
  end
end
