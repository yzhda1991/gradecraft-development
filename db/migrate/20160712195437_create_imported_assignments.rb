class CreateImportedAssignments < ActiveRecord::Migration
  def change
    create_table :imported_assignments do |t|
      t.references :assignment, index: true, foreign_key: true
      t.string :provider, null: false
      t.string :provider_id, null: false

      t.timestamps null: false
    end
  end
end
