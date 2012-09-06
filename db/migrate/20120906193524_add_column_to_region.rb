class AddColumnToRegion < ActiveRecord::Migration
  def change
    add_column :regions, :display, :boolean
    add_index :regions, :name, :unique => true
  end
end
