class Instance < ActiveRecord::Base
  attr_accessible :architecture, :availability_zone, :aws_id, :image_id, :instance_type, :ip_address, :launch_time, :platform, :private_ip_address, :root_device_type, :status
  belongs_to :region
end
