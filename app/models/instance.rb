class Instance < ActiveRecord::Base
  attr_accessible :architecture, :availability_zone, :aws_id, :image_id, :instance_type, :ip_address, :launch_time, :platform, :private_ip_address, :root_device_type, :status, :key_pair, :security_group, :name, :existing, :region, :region_id, :cluster_name, :role, :region_name

  attr_accessor :existing, :region_name, :cluster_name, :role

  validates :key_pair, :presence => true
  validates :image_id, :presence => true
  validates :security_group, :presence => true

  before_save :create_instance_in_ec2
  before_destroy :destroy_instance_in_ec2
  belongs_to :region

  def self.available_image_ids(region_name)
    ec2 = AWS::EC2.new
    ec2 = ec2.regions[region_name]
    ec2.images.with_owner('self').collect{ |i| ["#{i.name} (#{i.id})", i.id]}
  end

  def self.available_security_groups(region_name)
    ec2 = AWS::EC2.new
    ec2 = ec2.regions[region_name]
    ec2.security_groups.collect{ |g| [g.name, g.id] }
  end

  def self.available_key_pairs(region_name)
    ec2 = AWS::EC2.new
    ec2 = ec2.regions[region_name]
    ec2.key_pairs.map(&:name)
  end

  def self.availability_zones(region_name)
    ec2 = AWS::EC2.new
    ec2 = ec2.regions[region_name]
    ec2.availability_zones.map(&:name)
  end

  private
  def create_instance_in_ec2
    return if existing
    ec2 = AWS::EC2.new
    ec2 = ec2.regions[region_name]
    begin
      image = ec2.images[image_id]
      group = ec2.security_groups[security_group]
      pair = ec2.key_pairs[key_pair]
      i = image.run_instance(:key_pair => pair,
                            :security_groups => group,
                            :instance_type => instance_type,
                            :availability_zone => availability_zone)
      i.tag('cluster', :value => cluster_name)
      i.tag('role', :value => role)
      i.tag('Name', :value => "#{cluster_name}-#{role}")
    rescue
      logger.debug "Error"
      return false
    end
    self.status = i.status.to_s
    self.key_pair = i.key_pair.name
    self.security_group = group.name
    self.launch_time = i.launch_time
    self.architecture = i.architecture
    self.availability_zone = i.availability_zone
    self.aws_id = i.id
    self.name = "#{cluster_name}-#{role}"
    self.region = Region.where(['name = ?', ec2.name]).first
  end

  def destroy_instance_in_ec2
    ec2 = AWS::EC2.new
    ec2 = ec2.regions[region.name]
    begin
      i = ec2.instances[aws_id]
      i.terminate
    rescue Exception => e
      logger.debug "Error: #{e.message}"
      return false
    end
  end

  def self.refresh_instances_from_aws
    updated_aws_ids = []
    ec2 = AWS::EC2.new
    AWS::start_memoizing
    region_names = ec2.regions.map(&:name)
    region_names.each do |region_name|
      ec2_region = ec2.regions[region_name]
      unless local_region = Region.where(['name = ?', region_name]).first
        local_region = Region.create!({:name => region_name}) 
      end
      local_region.update_attribute(:display, ec2_region.instances.count > 0)
    end
    region_names.each do |region_name|
      local_region = Region.where(['name = ?', region_name]).first
      logger.debug "local region name = #{local_region.name}"
      ec2_region = ec2.regions[region_name]
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
            when 'region_id'
              instance_data['region_id'] = local_region.id
            when 'security_group'
              #TODO allow multiple
              instance_data[c.name] = instance.security_groups.first.name
            else
              instance_data[c.name] = instance.send(c.name).to_s if instance.respond_to? c.name
          end
        end
        logger.debug instance_data.inspect
        if i = Instance.where(['aws_id = ?', instance_data['aws_id']]).first
          i.update_attributes!(instance_data)
        else
          Instance.create!(instance_data)
        end
        updated_aws_ids << instance_data['aws_id']
      end
    end
    AWS::stop_memoizing
    Instance.where(["aws_id NOT IN (?)", updated_aws_ids]).each do |i|
      i.delete
    end
  end
end
