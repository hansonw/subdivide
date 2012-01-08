class AddUuidToVideo < ActiveRecord::Migration
  def up
    add_column :videos, :uuid, :string
  end
  def down
    remove_column :videos, :uuid
  end
end
