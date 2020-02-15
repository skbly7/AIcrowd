ActiveAdmin.register Leaderboard do
  belongs_to :challenge, parent_class: Challenge
  navigation_menu :challenge

  config.sort_order = 'row_num: :asc'

  actions :index, :show

  filter :id
  filter :submitter_type
  filter :submitter_id
  filter :name
  filter :media_content_type
  filter :submission_id
  filter :challenge_round_id

  controller do
    def scoped_collection
      super.includes :participant, :team, :challenge_round
    end
  end

  index do
    selectable_column
    column 'Rank', &:row_num
    column 'Leaderboard ID', &:id
    column :submission_id
    column :challenge_round_id
    column 'Round' do |res|
      res.challenge_round.challenge_round
    end
    column :team
    column :participant
    column 'Email' do |res|
      res.participant&.email
    end
    column :score
    column :score_secondary
    column :post_challenge
    column :media_thumbnail
    column :updated_at
    actions
  end

  csv do
    column 'Rank', &:row_num
    column 'Leaderboard ID', &:id
    column :submission_id
    column :challenge_round_id
    column 'Round' do |res|
      res.challenge_round.challenge_round
    end
    column :team
    column :participant
    column 'Email' do |res|
      res.participant&.email
    end
    column :score
    column :score_secondary
    column :post_challenge
    column :media_thumbnail
    column :updated_at
  end

  batch_action 'Re-Evaluate Submissions ', priority: 1 do |ids|
    batch_action_collection.find(ids).each do |leaderboard|
      SubmissionGraderJob.perform_later(leaderboard.submission_id)
    end
    redirect_to admin_challenge_leaderboards_path, alert: 'Submissions are being revaluated'
  end
end
