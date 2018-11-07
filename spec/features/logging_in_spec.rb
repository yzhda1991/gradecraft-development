feature "logging in" do
  let(:password) { "p@ssword" }

  context "as a student" do
    let!(:course_membership) { create :course_membership, :student, user: user }
    let(:user) { create :user, password: password }

    before { visit root_path }

    scenario "with a password successfully" do
      LoginPage.new(user).submit({ password: password })

      expect(current_path).to eq dashboard_path
      within("header") do
        expect(page).to have_content user.first_name
      end
    end

    scenario "with an invalid email and password combination" do
      LoginPage.new(user).submit({ password: "blah" })
      expect(current_path).to eq root_path
      expect(page).to have_content "Your username or password is incorrect. Please try again"
    end
  end
end
