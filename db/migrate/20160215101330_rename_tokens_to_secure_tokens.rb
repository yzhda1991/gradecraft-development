class RenameTokensToSecureTokens < ActiveRecord::Migration
  def change
    rename_table :tokens, :secure_tokens
  end
end
