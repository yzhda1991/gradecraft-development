class CreateImportedGrades < ActiveRecord::Migration
  def change
    create_table :imported_grades do |t|
      t.references :grade, index: true, foreign_key: true
      t.string :provider
      t.string :provider_resource_id

      t.timestamps null: false
    end
  end
end
