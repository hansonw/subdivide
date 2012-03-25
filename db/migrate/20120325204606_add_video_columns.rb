class AddVideoColumns < ActiveRecord::Migration
  def up
    add_column :videos, :title, :string
    add_column :videos, :yt_url, :string
  end

  def down
    remove_column :videos, :title
    remove_column :videos, :yt_url
  end
end
