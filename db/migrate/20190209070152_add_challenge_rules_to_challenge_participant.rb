class AddChallengeRulesToChallengeParticipant < ActiveRecord::Migration[5.2]
    def change
      add_column :challenge_participants, :challenge_rules_accepted_date, :datetime
      add_column :challenge_participants, :challenge_rules_accepted_version, :integer
      add_column :challenge_participants, :challenge_rules_additional_checkbox, :boolean, default: false
    end
  end
