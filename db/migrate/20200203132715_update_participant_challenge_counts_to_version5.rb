class UpdateParticipantChallengeCountsToVersion5 < ActiveRecord::Migration[5.2]
  def change
    update_view :participant_challenge_counts, version: 5, revert_to_version: 4
  end
end
