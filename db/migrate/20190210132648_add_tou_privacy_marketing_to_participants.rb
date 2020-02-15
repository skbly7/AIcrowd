class AddTouPrivacyMarketingToParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :participants, :agreed_to_terms_of_use_and_privacy, :boolean, default: false
    add_column :participants, :agreed_to_marketing, :boolean, default: false
  end
end
