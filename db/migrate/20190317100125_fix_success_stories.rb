class FixSuccessStories < ActiveRecord::Migration[5.2]
  def change
  	rename_column :success_stories, :body, :byline
  	rename_column :success_stories, :body_markdown, :html_content
  	add_column :success_stories, :slug, :string
  end
end
