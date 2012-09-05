class AddMoreFieldsToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :security_group, :string
    add_column :instances, :key_pair, :string
  end
end
