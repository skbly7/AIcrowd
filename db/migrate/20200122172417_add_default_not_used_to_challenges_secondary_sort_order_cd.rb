class AddDefaultNotUsedToChallengesSecondarySortOrderCd < ActiveRecord::Migration[5.2]
  def change
    change_column :challenges, :secondary_sort_order_cd, :string, default: 'not_used'
  end
end
