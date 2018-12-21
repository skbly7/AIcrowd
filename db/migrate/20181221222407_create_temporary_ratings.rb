class CreateTemporaryRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :temporary_ratings do |t|
 		  t.references :participant, foreign_key: true
      t.float :mean, default: 25.0
      t.float :deviation, default: 8.333
      
      t.timestamps
    end
  end
end
