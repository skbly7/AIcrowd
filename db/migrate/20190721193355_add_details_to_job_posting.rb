class AddDetailsToJobPosting < ActiveRecord::Migration[5.2]
  def change
    add_column :job_postings, :slug, :string
    add_column :job_postings, :description_markdown, :text
  end
end
