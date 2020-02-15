class UpdateChallengeRegistrationsViewToVersion2 < ActiveRecord::Migration[5.2]
  def change
    drop_view   :participant_challenges
    update_view :challenge_registrations, version: 2, revert_to_version: 1
    create_view :participant_challenges, version: 7
  end
end
