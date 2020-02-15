class CreateTeamMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :team_members do |t|
      t.string :name
      t.string :title
      t.string :section
      t.string :description
      t.integer :seq
      t.belongs_to :participant, foreign_key: true
      t.timestamps
    end
    add_index :team_members, :name
  end
end
