class CreateImportedUsers < ActiveRecord::Migration
  def change
    create_table :imported_users do |t|
      t.references :user, index: true, foreign_key: true
      t.string :provider
      t.string :provider_resource_id
      t.datetime :last_imported_at

      t.timestamps null: false
    end
  end
end
