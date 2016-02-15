class RenameHashedKeyToEncryptedKey < ActiveRecord::Migration
  def change
    rename_column :tokens, :hashed_key, :encrypted_key
    add_column :tokens, :token_id_hex, :string
    add_column :tokens, :target_class, :string
    add_column :tokens, :target_id, :integer
  end
end
