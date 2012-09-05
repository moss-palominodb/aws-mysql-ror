class AddFieldsToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :region_id, :integer
    add_column :instances, :name, :string
  end
end
