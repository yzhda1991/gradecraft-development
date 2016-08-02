class UserAuthorization < ActiveRecord::Base
  belongs_to :user

  def self.create_by_auth_hash(auth_hash, user)
    provider = auth_hash["provider"]
    access_token = auth_hash["credentials"]["token"]

    authorization = self.find_or_initialize_by provider: provider, user_id: user.id
    authorization.update_attributes access_token: access_token
    authorization
  end

  def self.for(user, provider)
    where(user_id: user.id, provider: provider).first
  end
end
