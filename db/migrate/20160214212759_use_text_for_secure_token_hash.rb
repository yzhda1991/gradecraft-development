class UseTextForSecureTokenHash < ActiveRecord::Migration
  def up
    change_column :tokens, :hashed_key, :text
  end

  def down
    change_column :tokens, :hashed_key, :string
  end
end
