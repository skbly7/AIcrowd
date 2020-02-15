ActiveAdmin.register SuccessStory do
  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end

    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    column :seq
    column :title
    column :published
    column :posted_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :seq
      f.input :published
      f.input :byline
      f.input :slug
      f.input :image_file
      f.input :html_content
      f.input :posted_at
    end
    f.actions
  end

  show do |success_story|
    attributes_table do
      row :title
      row :slug
      row :seq
      row :published
      row :byline
      row :posted_at
      row :created_at
      row :updated_at
    end
  end
end
