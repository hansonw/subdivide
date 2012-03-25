class RemoveTimePoints < ActiveRecord::Migration
  def up
    drop_table :time_points
  end

  def down
    create_table :time_points do |t|
      t.string   "time"
      t.integer  "voice"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "time_point_type"
      t.integer  "video_id"

      t.timestamps
    end
  end
end
