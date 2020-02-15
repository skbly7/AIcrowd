class AddDiscourseIdToChallenge < ActiveRecord::Migration[5.2]
  def change
    add_column :challenges, :discourse_category_id, :integer
    execute "update challenges set toc_accordion = false;"
  end
end