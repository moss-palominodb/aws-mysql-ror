class CreateInstanceTypes < ActiveRecord::Migration
  def self.up
    create_table :instance_types do |t|
      t.string :name
      t.timestamps
    end
    ['t1.micro', 'm1.small', 'c1.medium', 'm1.medium', 'm1.large', 'm1.xlarge', 'm2.xlarge', 'm2.2xlarge', 'm2.4xlarge', 'c1.xlarge'].each do |t|
      InstanceType.create(:name => t)
    end

  end

  def self.down
    drop_table :instance_types
  end
end
