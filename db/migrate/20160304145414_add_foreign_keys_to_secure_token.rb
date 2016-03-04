class AddForeignKeysToSecureToken < ActiveRecord::Migration
  def change
    add_column :secure_tokens, :user_id, :integer
    add_column :secure_tokens, :course_id, :integer
  end
end
