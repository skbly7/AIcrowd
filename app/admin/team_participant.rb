ActiveAdmin.register TeamParticipant do
  menu false

  controller do
    def scoped_collection
      super.includes :participant, team: :challenge
    end
  end

  index do
    selectable_column
    if params[:challenge_id].blank?
      column :challenge do |tp|
        link_to tp.team.challenge.challenge, admin_challenge_path(tp.team.challenge)
      end
    end
    if params[:team_name].blank?
      column :team do |tp|
        link_to tp.team.name, admin_challenge_team_path(tp.team.challenge, tp.team)
      end
    end
    column :participant
    column :role
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :participant
      row :role
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :participant, collection: Participant.order(:slug).pluck(:slug, :id)
      f.input :role, as: :select, collection: TeamParticipant::ROLES.map { |x| [x.to_s.titleize, x] }
    end
    f.actions
  end
end
