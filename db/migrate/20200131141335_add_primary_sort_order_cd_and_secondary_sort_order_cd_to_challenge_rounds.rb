class AddPrimarySortOrderCdAndSecondarySortOrderCdToChallengeRounds < ActiveRecord::Migration[5.2]
  def change
    add_column :challenge_rounds, :primary_sort_order_cd, :string, null: false, default: :ascending
    add_column :challenge_rounds, :secondary_sort_order_cd, :string, null: false, default: :not_used
  end
end
