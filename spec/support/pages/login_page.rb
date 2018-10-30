class LoginPage
  include Capybara::DSL

  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def submit(fields={})
    within("div#access_gate") do
      fill_in "Email", with: fields[:email] || user.email
      fill_in "Password", with: fields[:password] || user.password
      click_button "Log in"
    end
  end
end
