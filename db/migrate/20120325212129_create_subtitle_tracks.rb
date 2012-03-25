class CreateSubtitleTracks < ActiveRecord::Migration
  def change
    create_table :subtitle_tracks do |t|
      t.string :title

      t.timestamps
    end
  end
end
