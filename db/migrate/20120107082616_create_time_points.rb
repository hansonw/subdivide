class CreateTimePoints < ActiveRecord::Migration
  def change
    create_table :time_points do |t|
      t.string :time
      t.integer :type
      t.integer :voice

      t.timestamps
    end
  end
end
