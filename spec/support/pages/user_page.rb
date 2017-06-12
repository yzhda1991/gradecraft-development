class UserPage
  include Capybara::DSL

  attr_accessor :user

  def initialize(user)
    @user = user
  end

  protected

  def fill_out_form(fields={})
    fill_in "First name", with: fields[:first_name] || user.first_name
    fill_in "Last name", with: fields[:last_name] || user.last_name
    fill_in "Email", with: fields[:email] || user.email
    select "Student", from: "user_course_memberships_attributes_0_role"
  end
end
