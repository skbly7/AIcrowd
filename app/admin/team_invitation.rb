ActiveAdmin.register TeamInvitation do
  menu false

  controller do
    defaults finder: :find_by_uuid
    def scoped_collection
      super.includes :team, :invitor, :invitee
    end
  end

  index do
    selectable_column
    if params[:challenge_id].blank?
      column :challenge do |ti|
        link_to ti.team.challenge.challenge, admin_challenge_path(ti.team.challenge)
      end
    end
    if params[:team_name].blank?
      column :team do |ti|
        link_to ti.team.name, admin_challenge_team_path(ti.team.challenge, ti.team)
      end
    end
    column :invitor
    column :invitee
    column :status
    column :uuid
    column :created_at
    column :updated_at
    actions
  end
end
