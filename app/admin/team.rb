ActiveAdmin.register Team do
  config.sort_order = 'name_asc'
  belongs_to :challenge, optional: true
  permit_params :name, :challenge_id

  controller do
    defaults finder: :find_by_name
    def scoped_collection
      super.includes :challenge
    end

    def create
      create! do |format|
        format.html { redirect_to admin_challenge_team_path(@team.challenge, @team) }
      end
    end

    def destroy
      destroy! do |format|
        format.html { redirect_to params[:return_to].presence || admin_challenge_team_path(@team.challenge, @team) }
      end
    end
  end

  sidebar 'Associations', only: [:show, :edit] do
    ul do
      li link_to "Team Participants (#{team.team_participants.count})", admin_challenge_team_team_participants_path(team.challenge, team)
      li link_to "Team Invitations (#{team.team_invitations.count})", admin_challenge_team_team_invitations_path(team.challenge, team)
    end
  end

  action_item only: :index, priority: 0 do
    link_to('All Teams', admin_teams_path) if params[:challenge_id].present?
  end

  index do
    selectable_column
    column :name
    column :challenge, sortable: 'challenges.challenge' do |team|
      link_to team.challenge.challenge, admin_challenge_path(team.challenge)
    end
    column :created_at
    column :updated_at
    actions defaults: false do |team|
      delete_return_to = if params[:challenge_id].present?
                           admin_challenge_teams_path(team.challenge)
                         else
                           admin_teams_path
                         end
      item 'View', admin_challenge_team_path(team.challenge, team), class: 'member_link'
      item 'Edit', edit_admin_challenge_team_path(team.challenge, team), class: 'member_link'
      item 'Delete', admin_challenge_team_path(team.challenge, team, return_to: delete_return_to), method: :delete, class: 'member_link'
    end
  end

  show do
    attributes_table do
      row :name
      row :challenge do |team|
        link_to team.challenge.challenge, admin_challenge_path(team.challenge)
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :challenge, collection: Challenge.all.map { |x| [x.challenge, x.id] }
      f.input :name, as: :string
    end
    f.actions
  end
end
