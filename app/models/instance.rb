class Instance < ActiveRecord::Base
  attr_accessible :architecture, :availability_zone, :aws_id, :image_id, :instance_type, :ip_address, :launch_time, :platform, :private_ip_address, :root_device_type, :status, :key_pair, :security_group

  validates :key_pair, :presence => true
  validates :image_id, :presence => true
  validates :security_group, :presence => true

  before_save :create_instance_in_ec2
  belongs_to :region

  def self.available_image_ids
    ec2 = AWS::EC2.new
    ec2 = ec2.regions['us-west-1']
    ec2.images.with_owner('self').map(&:id)
  end

  def self.available_security_groups
    ec2 = AWS::EC2.new
    ec2 = ec2.regions['us-west-1']
    ec2.security_groups.map(&:name)
  end

  def self.available_key_pairs
    ec2 = AWS::EC2.new
    ec2 = ec2.regions['us-west-1']
    ec2.key_pairs.map(&:name)
  end

  private
  def create_instance_in_ec2
    return false
    ec2 = AWS::EC2.new
    # change region ec2 = ec2.regions['region-name']
    ec2 = ec2.regions['us-west-1']
    begin
      image = ec2.images[image_id]
      group = ec2.security_groups[security_group]
      pair = ec2.key_pairs[key_pair]
      instance = image.run_instance(:key_pair => 'asdf',
                                    :security_groups => group)
    rescue
      return false
    end
    self.status = instance.status.to_s
    logger.debug "Status = #{instance.status.to_s}"
    logger.debug "self.status = #{self.status}"
    self.launch_time = instance.launch_time
    logger.debug "Launch Time = #{instance.launch_time}"
    logger.debug "self.launch_time = #{self.launch_time}"
  end

  def self.instances_from_aws
    # placeholder removed from former account.rb model
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
