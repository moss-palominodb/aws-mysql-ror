ActiveAdmin.register_page "Create Cluster" do
  content do
    div do
      form :action => new_cluster_admin_instances_path, :method => :post do |f|
        div "Number of slaves:"
        div f.input :name => :slave_count, :type => :select      
        div "Cluster Name:"
        div f.input :name => :cluster_name      
        div "Region:"
        div f.select options_for_select(Region.where(:display => true).map(&:name)), { :name => "region_name" }
        div f.input :type => :submit
      end
    end
  end
end
