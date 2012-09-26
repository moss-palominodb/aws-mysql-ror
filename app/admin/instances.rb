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
    column "Status" do |i|
      i.status
    end
    column :instance_type
    column "" do |i|
      link_to "Terminate", terminate_admin_instance_path(i), {:confirm => "Are you sure you want to terminate #{i.name} (#{i.aws_id})?", :method => :post}
    end
  end

  action_item do 
    link_to('Refresh', refresh_admin_instances_path) 
  end 

  member_action :terminate, :method => :post do
    i = Instance.find(params[:id])
    i.destroy
    redirect_to '/admin/instances', :notice => "Terminated instance #{i.name} (#{i.aws_id})"
  end

  batch_action :destroy, :confirm => "Are you sure you want to terminate all of these instances?" do |selection|
    Instance.find(selection).each { |i| i.destroy }
    redirect_to collection_path, :notice => "Instances terminated"
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
      instance = Instance.create!(params["instance_#{i}"].merge({:region_name => params['region_name']}))
      ids << instance.aws_id
      logger.debug instance.inspect
      logger.debug("##{i} is #{instance.valid? ? 'Valid' : 'Invalid'}")
    end
    redirect_to '/admin/instances', :notice => "Created #{instance_indexes.length} new instances: #{ids.join(', ')}"
  end 
end
