class CreateSuccessStories < ActiveRecord::Migration[5.2]
	def change
		create_table :success_stories do |t|
			t.bigint :participant_id
			t.string :title
			t.text :body
			t.text :body_markdown
			t.boolean :published
			t.datetime :posted_at
			t.integer :seq
			t.timestamps
		end
	end
end
