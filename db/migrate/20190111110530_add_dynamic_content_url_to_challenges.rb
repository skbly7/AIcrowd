class AddDynamicContentUrlToChallenges < ActiveRecord::Migration[5.2]
  def change
    add_column :challenges, :dynamic_content_url, :string
  end
end