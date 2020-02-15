class AddSlugToBlog < ActiveRecord::Migration[5.2]
  def change
    add_column :blogs, :slug, :string
  end
end
