class AddExpirationToUserAuthorizations < ActiveRecord::Migration
  def change
    add_column :user_authorizations, :refresh_token, :string
    add_column :user_authorizations, :expires_at, :datetime
  end
end
