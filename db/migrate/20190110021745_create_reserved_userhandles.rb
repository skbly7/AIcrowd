class CreateReservedUserhandles < ActiveRecord::Migration[5.2]
  def change
    create_table :reserved_userhandles do |t|
      t.string :name

      t.timestamps
    end
    add_index :reserved_userhandles, :name, unique: true
  end
end
