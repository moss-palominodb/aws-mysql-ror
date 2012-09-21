ActiveAdmin.register Instance do

  form do |f|
    f.inputs "Parameters" do
      f.input :region_name, :as => :select,
                         :collection => Region.where(:display => true).map(&:name),
                         :selected => AwsConsole::Application::DEFAULT_REGION
      f.input :image_id, :as => :select,
                         :collection => Instance.available_image_ids
      f.input :security_group, :as => :select,
                         :collection => Instance.available_security_groups
      f.input :key_pair, :as => :select,
                         :collection => Instance.available_key_pairs
    end
    f.buttons
  end

  index do
    column :name
    column "AWS ID", :aws_id
    column :availability_zone
    column "Region" do |i|
      i.region.name if i.region
    end
    column :architecture
    column "Image ID", :image_id
    column :status
    column :instance_type
  end

  action_item do 
    link_to('Refresh', refresh_admin_instances_path) 
  end 

  collection_action :refresh, :method => :get do 
    Instance.refresh_instances_from_aws
    redirect_to '/admin/instances'
  end 

  collection_action :new_cluster, :method => :post do 
  end 

  collection_action :create_cluster, :method => :post do 
    instance_indexes = params['instance_indexes']
    ids = []
    instance_indexes.each do |i|
      instance = Instance.create!(params["instance_#{i}"])
      ids << instance.aws_id
      logger.debug("##{i} is #{instance.valid? ? 'Valid' : 'Invalid'}")
    end
    redirect_to '/admin/instances', :notice => "Created #{instance_indexes.length} new instances: #{ids.join(', ')}"
  end 
end
