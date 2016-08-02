class UserAuthorization < ActiveRecord::Base
  belongs_to :user

  def self.for(user, provider)
    where(user_id: user.id, provider: provider).first
  end
end
