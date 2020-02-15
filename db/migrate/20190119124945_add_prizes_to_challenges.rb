class AddPrizesToChallenges < ActiveRecord::Migration[5.2]
  def change
    add_column :challenges, :prize_cash, :string
    add_column :challenges, :prize_travel, :integer
    add_column :challenges, :prize_academic, :integer
    add_column :challenges, :prize_misc, :string
  end
end
