class CreateChallengeRules < ActiveRecord::Migration[5.2]
  def change
    create_table :challenge_rules do |t|
      t.references :challenge, foreign_key: true
      t.column :terms, :text
      t.column :terms_markdown, :text
      t.column :instructions, :text
      t.column :instructions_markdown, :text
      t.column :has_additional_checkbox, :boolean, default: false
      t.column :additional_checkbox_text, :string
      t.column :version, :integer, default: 1
      t.timestamps
    end
  end
end
