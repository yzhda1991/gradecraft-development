class CreateInstitutions < ActiveRecord::Migration[5.0]
  def change
    create_table :institutions do |t|
      t.string :name, null: false
      t.boolean :has_site_license, null: false, default: false
    end
    add_index :institutions, :name
  end
end
