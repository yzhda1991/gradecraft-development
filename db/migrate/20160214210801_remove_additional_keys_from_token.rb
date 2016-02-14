class RemoveAdditionalKeysFromToken < ActiveRecord::Migration
  def change
    rename_column :tokens, :hashed_key1, :hashed_key
    remove_column :tokens, :hashed_key2
    remove_column :tokens, :hashed_key3
  end
end
