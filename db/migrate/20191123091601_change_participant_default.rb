class ChangeParticipantDefault < ActiveRecord::Migration[5.2]
  def up
    change_column_default :participants, :agreed_to_terms_of_use_and_privacy, true
    change_column_default :participants, :agreed_to_marketing, true
  end

  def down
    change_column_default :participants, :agreed_to_terms_of_use_and_privacy, false
    change_column_default :participants, :agreed_to_marketing, false
  end
end