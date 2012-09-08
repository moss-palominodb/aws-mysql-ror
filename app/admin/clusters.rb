ActiveAdmin.register_page "Create Cluster" do
  content do
    div do
      form :action => new_cluster_admin_instances_path, :method => :post do |f|
        div f.input :name => :slave_count, :type => :select      
        div f.input :name => :cluster_name      
        div f.input :type => :submit
      end
    end
  end
end
