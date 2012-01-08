class AddVideoIdToTimePoint < ActiveRecord::Migration
  def up
    add_column :time_points, :video_id, :integer
  end
  def down
    remove_column :time_points, :video_id
  end
end
