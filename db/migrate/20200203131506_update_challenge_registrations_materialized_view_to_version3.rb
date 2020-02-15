class UpdateChallengeRegistrationsMaterializedViewToVersion3 < ActiveRecord::Migration[5.2]
  def change
    drop_view   :participant_challenges

    update_view :challenge_registrations, version: 3, revert_to_version: 2

    create_view :participant_challenges, version: 7
  end
end
