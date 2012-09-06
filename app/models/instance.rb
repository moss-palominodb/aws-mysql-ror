class Instance < ActiveRecord::Base
  attr_accessible :architecture, :availability_zone, :aws_id, :image_id, :instance_type, :ip_address, :launch_time, :platform, :private_ip_address, :root_device_type, :status, :key_pair, :security_group, :name, :existing, :region

  attr_accessor :existing, :region_name

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
    return if existing
    ec2 = AWS::EC2.new
    # change region ec2 = ec2.regions['region-name']
    ec2 = ec2.regions[region_name]
    begin
      image = ec2.images[image_id]
      group = ec2.security_groups[security_group]
      pair = ec2.key_pairs[key_pair]
      i = image.run_instance(:key_pair => pair,
                                    :security_groups => group)
    rescue
      logger.debug "Error"
      return false
    end
    self.status = i.status.to_s
    self.launch_time = i.launch_time
    self.architecture = i.architecture
    self.availability_zone = i.availability_zone
    self.aws_id = i.id
  end

  def self.refresh_instances_from_aws
    ec2 = AWS::EC2.new
    region_names = ec2.regions.map(&:name)
    region_names.each do |region_name|
      ec2_region = ec2.regions[region_name]
      unless local_region = Region.where(['name = ?', region_name]).first
        local_region = Region.create!({:name => region_name}) 
      end
      local_region.update_attribute(:display, ec2_region.instances.length > 0)
    end
    region_names.each do |region_name|
      ec2_region.instances.each do |instance|
        name = "BLANK"
        instance.tags.each do |tag|
          if tag[0] == "Name"
            name = tag[1]
            break
          end
        end
        instance_data = {:name => name, :existing => true}
        Instance.columns.each do |c|
          case c.name
            when 'id'
            when 'aws_id'
              instance_data[c.name] = instance.id
            when 'key_pair'
              instance_data[c.name] = instance.key_pair.name
            when 'region'
              instance_data[c.name] = local_region
            when 'security_group'
              #TODO allow multiple
              instance_data[c.name] = instance.security_groups.first.name
            else
              instance_data[c.name] = instance.send(c.name).to_s if instance.respond_to? c.name
          end
        end
        logger.debug "Instance Data:"
        logger.debug instance_data.inspect
        if i = Instance.where(['aws_id = ?', instance_data['aws_id']]).first
          i.update_attributes!(instance_data)
        else
          Instance.create!(instance_data)
        end
      end
    end
  end
end
