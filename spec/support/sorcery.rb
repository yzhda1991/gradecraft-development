module Sorcery
  module TestHelpers
    module Rails
      module Integration
        def login_user(user, password)
          page.driver.post(user_sessions_path, { email: user.email, password: password}) 
        end
      end
    end
  end
end