ActiveAdmin.register_page "Create An Instance" do
  content do
    form :action => "/instance/create" do |f|
      f.input :title
      f.input :published_at, :label => "Publish Post At"
      f.input :category
      f.input :body
      f.button "Create"
    end
  end
end
