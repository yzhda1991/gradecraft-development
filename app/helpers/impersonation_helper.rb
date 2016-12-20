module ImpersonationHelper
  def impersonating_agent(user)
    session[:impersonating_agent_id] = user.id
  end

  def delete_impersonating_agent
    session.delete :impersonating_agent_id
  end

  def impersonating_agent_id
    session[:impersonating_agent_id]
  end

  def student_impersonation?
    impersonating_agent_id.present?
  end
end
