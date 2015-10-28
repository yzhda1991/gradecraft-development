module SorceryStubbing
  class TestUserMailer
    def self.activation_needed_email(_); end
    def self.activation_success_email(_); end
  end

  def self.sorcery_reset(submodules, options={})
    unless defined?(GradeCraft::Application)
      ::Sorcery::Controller::Config.init!
      ::Sorcery::Controller::Config.reset!
      ::Sorcery::Controller::Config.submodules = submodules
      ::Sorcery::Controller::Config.user_config do |user|
        options.each { |property, value| user.send(:"#{property}=", value) }
      end
    end
  end

  def login_user(user, password)
    page.driver.post(login_path, { username: user, password: password}) 
  end
end
