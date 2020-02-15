class AddMarkdownToRulesCheckbox < ActiveRecord::Migration[5.2]
  def change
    add_column :challenge_rules, :additional_checkbox_text_markdown, :string
  end
end
