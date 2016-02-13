class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.datetime :expires_at
      t.string :hashed_key1
      t.string :hashed_key2
      t.string :hashed_key3

      t.timestamps null: false
    end
  end
end
