class RenameTimePointColumn < ActiveRecord::Migration
  def up
    remove_column :time_points, :type
    add_column :time_points, :time_point_type, :integer
  end

  def down
    remove_column :time_points, :time_point_type
    add_column :time_points, :type, :integer
  end
end
