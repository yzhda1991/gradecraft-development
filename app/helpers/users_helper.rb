module UsersHelper
  def generate_random_password
    Sorcery::Model::TemporaryToken.generate_random_token
  end
end
