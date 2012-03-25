class CreateSubtitleTrackSets < ActiveRecord::Migration
  def change
    create_table :subtitle_track_sets do |t|
      t.string :title

      t.timestamps
    end
  end
end
