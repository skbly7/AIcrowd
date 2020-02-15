class CreateMigrationMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :migration_mappings do |t|
      t.string :source_type
      t.integer :source_id
      t.integer :crowdai_participant_id
      t.timestamps
    end
  end
end