ActiveAdmin.register Blog do
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
    column :slug
    column :participant
    column :published
    column :vote_count
    column :view_count
    column :posted_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :participant
      f.input :title
      f.input :slug
      f.input :seq
      f.input :published
      f.input :body_markdown
      f.input :posted_at
    end
    f.actions
  end

  show do |blog|
    attributes_table do
      row :participant
      row :title
      row :slug
      row :seq
      row :published
      row :body do
        sanitize(blog.body)
      end
      row :posted_at
      row :created_at
      row :updated_at
    end
  end
end
