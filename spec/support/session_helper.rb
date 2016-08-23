module SessionHelper
  def login_as_impersonating_agent(agent, student)
    login_user(student)
    session[:impersonating_agent_id] = agent.id
  end
end
