ActiveAdmin.register Challenge do
  sidebar "Challenge Configuration", only: [:show, :edit] do
    ul do
      li link_to "Dataset Files", admin_challenge_dataset_files_path(challenge)
      li link_to "Submission File Definition", admin_challenge_submission_file_definitions_path(challenge)
    end
  end

  sidebar "Challenge Details", only: [:show, :edit] do
    ul do
      li link_to "Leaderboard (#{challenge.leaderboards.size} rows)", admin_challenge_leaderboards_path(challenge)
      li link_to "Submissions (#{challenge.submissions.length})", admin_challenge_submissions_path(challenge)
      li link_to "Teams (#{challenge.teams.size})", admin_challenge_teams_path(challenge)
    end
  end

  filter :id
  filter :status_cd
  filter :challenge

  index do
    selectable_column
    column :id
    column :challenge
    column :status
    column :featured_sequence
    column :page_views
    column :participant_count
    column :submissions_count
    actions
  end

  controller do
    actions :all, except: [:edit, :new]
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end

    def permitted_params
      params.permit!
    end
  end

  member_action :purge, method: :delete do
    submissions       = Submission.where(challenge_id: params[:id])
    submissions_count = submissions.count
    submissions.destroy_all
    redirect_to admin_challenge_path(params[:id]), flash: { notice: "#{submissions_count} submissions have been deleted." }
  end

  action_item :delete_submissions, only: :show do
    link_to 'Delete all submissions', purge_admin_challenge_path(resource.id), method: :delete, data: { confirm: "You are about to delete all submissions for #{resource.challenge} challenge. Are you sure?" }
  end

  action_item :reorder, only: :index do
    link_to 'Reorder Challenges Featured Sequence', reorder_challenges_path
  end

  batch_action "Recalculate the Leaderboard for ", priority: 1 do |ids|
    Challenge.find(ids).each do |challenge|
      challenge.challenge_rounds.each do |challenge_round|
        CalculateLeaderboardJob.perform_now(challenge_round_id: challenge_round.id)
      end
    end
    redirect_to admin_challenges_path, alert: "The Leaderboards for the selected challenges are being recalculated!."
  end
end
