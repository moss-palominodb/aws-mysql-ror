ActiveAdmin.register Instance do

  form do |f|
    f.inputs "Parameters" do
      f.input :image_id, :as => :select,
                         :collection => Instance.available_image_ids
      f.input :security_group, :as => :select,
                         :collection => Instance.available_security_groups
      f.input :key_pair, :as => :select,
                         :collection => Instance.available_key_pairs
    end
    f.buttons
  end

end
