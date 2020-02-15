class UpdateParticipantChallengeCountsViewToVersion4 < ActiveRecord::Migration[5.2]
  def change
    update_view :participant_challenge_counts, version: 4, revert_to_version: 3
  end
end
