class AddLogoToSuccessStories < ActiveRecord::Migration[5.2]
  def change
  	add_column :success_stories, :image_file, :string
  	remove_column :success_stories, :participant_id
  end
end
