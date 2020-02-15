class AddTermsToParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :participants, :participation_terms_accepted_date, :datetime
    add_column :participants, :participation_terms_accepted_version, :integer
  end
end
