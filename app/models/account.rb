class Account < ActiveRecord::Base
  attr_accessible :name
  INSTANCE_PARAMETERS = [
      'id',
      'status',
      'instance_type',
      'image_id',
      'launch_time',
      'availability_zone',
      'platform',
      'private_ip_address',
      'ip_address',
#      'group_set', # is a hash
      'architecture',
      'root_device_type',
      ]

  def self.instances
    ec2 = AWS::EC2.new
    region_names = ec2.regions.map(&:name)
    instances = []
    region_names.each do |region_name|
      region = ec2.regions[region_name]
      region.instances.each do |instance|
        name = "BLANK"
        instance.tags.each do |tag|
          if tag[0] == "Name"
            name = tag[1]
            break
          end
        end
        instance_data = {:name => name,
                         :region => region_name}
        Account::INSTANCE_PARAMETERS.each do |parameter|
          instance_data[parameter] = instance.send parameter
        end
        instances << instance_data
      end
    end
    instances
  end
end
