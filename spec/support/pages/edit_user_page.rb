require_relative "user_page"

class EditUserPage < UserPage
  include Capybara::DSL

  def submit(fields={})
    fill_out_form fields
    click_button "Update User"
  end
end
