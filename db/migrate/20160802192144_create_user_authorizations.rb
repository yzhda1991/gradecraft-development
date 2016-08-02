class CreateUserAuthorizations < ActiveRecord::Migration
  def change
    create_table :user_authorizations do |t|
      t.references :user, index: true, foreign_key: true
      t.string :provider
      t.string :access_token

      t.timestamps null: false
    end

    add_index :user_authorizations, [:user_id, :provider], unique: true
  end
end
