feature "logging in" do
  let(:password) { "p@ssword" }

  context "as a student" do
    let!(:course_membership) { create :course_membership, :student, user: user }
    let(:user) { create :user, password: password }

    before { visit new_user_session_path }

    scenario "with a password successfully" do
      LoginPage.new(user).submit({ password: password })

      expect(current_path).to eq dashboard_path
      within("header") do
        expect(page).to have_content user.first_name
      end
    end

    scenario "with an invalid email and password combination" do
      LoginPage.new(user).submit({ password: "blah" })
      expect(current_path).to eq user_sessions_path
      expect(page).to have_error_message "Email or Password were invalid, login failed."
    end
  end

end
