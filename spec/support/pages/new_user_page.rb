class NewUserPage
  include Capybara::DSL

  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def submit(fields={})
    fill_in "First name", with: fields[:first_name] || user.first_name
    fill_in "Last name", with: fields[:last_name] || user.last_name
    fill_in "Username", with: fields[:username] || user.username
    fill_in "Email", with: fields[:email] || user.email
    fill_in "Display name", with: fields[:display_name] || user.display_name
    check "UM User" if fields[:um_user]

    courses = fields[:courses]
    courses.each { |course| check course.name } if courses

    click_button "Create User"
  end
end
