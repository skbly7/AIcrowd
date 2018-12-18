class AddRatingToParticipants < ActiveRecord::Migration[5.2]
  def change
  	add_column :participants, :rating_mean, :decimal, default: 25.0
  	add_column :participants, :rating_sigma, :decimal, default: 8.3333
  	add_column :participants, :rating_temporary, :decimal, array: true, default: [25.0]
  end
end
