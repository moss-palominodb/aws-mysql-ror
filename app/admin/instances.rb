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

  action_item do 
    link_to('Refresh', refresh_admin_instances_path) 
  end 

  collection_action :refresh, :method => :get do 
    Instance.refresh_instances_from_aws
    redirect_to '/admin/instances'
  end 
end
