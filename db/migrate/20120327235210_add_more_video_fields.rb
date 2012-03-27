class AddMoreVideoFields < ActiveRecord::Migration
  def up
    add_column :videos, :thumbnail, :string
    add_column :videos, :uploader, :string
    add_column :videos, :desc, :string
    add_column :videos, :duration, :int
    add_column :videos, :views, :int
  end

  def down
    remove_column :videos, :thumbnail
    remove_column :videos, :uploader
    remove_column :videos, :desc
    remove_column :videos, :duration
    remove_column :videos, :views
  end
end
