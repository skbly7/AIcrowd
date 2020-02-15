ActiveAdmin.register TeamMember do
  config.sort_order = 'seq_asc'

  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :seq
    column :title
    column :description
    column :section
    column :participant
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.object.section     ||= "Main"
    f.object.description ||= "This field is unused right now!"
    f.object.seq         ||= (TeamMember.maximum(:seq) || 0) + 1
    f.inputs do
      f.input :name
      f.input :title
      f.input :description
      f.input :section
      f.input :participant
      f.input :seq
    end
    f.actions
  end
end
