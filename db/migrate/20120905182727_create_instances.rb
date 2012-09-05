class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.string :aws_id
      t.string :status
      t.string :instance_type
      t.string :image_id
      t.datetime :launch_time
      t.string :availability_zone
      t.string :platform
      t.string :private_ip_address
      t.string :ip_address
      t.string :architecture
      t.string :root_device_type

      t.timestamps
    end
  end
end
