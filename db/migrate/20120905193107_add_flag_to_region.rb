class AddFlagToRegion < ActiveRecord::Migration
  def change
    add_column :regions, :valid, :boolean
  end
end
