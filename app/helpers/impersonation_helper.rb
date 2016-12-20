module ImpersonationHelper
  def impersonate!(user)
    impersonating_agent current_user
    auto_login user
  end

  def unimpersonate!
    agent = User.find impersonating_agent_id
    auto_login agent
    delete_impersonating_agent
  end

  def impersonating_agent(user)
    session[:impersonating_agent_id] = user.id
  end

  def delete_impersonating_agent
    session.delete :impersonating_agent_id
  end

  def impersonating_agent_id
    session[:impersonating_agent_id]
  end

  def impersonating?
    impersonating_agent_id.present?
  end
end
