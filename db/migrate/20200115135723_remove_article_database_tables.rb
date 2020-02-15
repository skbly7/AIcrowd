class RemoveArticleDatabaseTables < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :article_sections, :articles
    remove_foreign_key :articles, :participants

    drop_table :article_sections
    drop_table :articles
  end
end
