class CreateProviders < ActiveRecord::Migration[5.0]
  def change
    create_table :providers do |t|
      t.string :name, null: false
      t.string :consumer_key, null: false
      t.string :consumer_secret, null: false
      t.string :base_url
      t.integer :provider_id
      t.integer :provider_type
      t.references :providee, polymorphic: true, index: true
    end

    add_index :providers, :name
  end
end
