class CreateParticipationTerms < ActiveRecord::Migration[5.2]
  def change
    create_table :participation_terms do |t|
      t.column :terms, :text
      t.column :terms_markdown, :text
      t.column :instructions, :text
      t.column :instructions_markdown, :text
      t.column :version, :integer, default: 1
      t.timestamps
    end
  end
end
