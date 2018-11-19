feature "logging out" do
  let(:password) { "p@ssword" }

  context "as a student" do
    let!(:course_membership) { create :course_membership, :student, user: user }
    let(:user) { create :user, password: password }

    before { visit root_path }

    before(:each) do
      LoginPage.new(user).submit({ password: password })
    end

    scenario "successfully" do
      within("#account-info") do
        click_link "Logout"
      end

      expect(current_path).to eq root_path
      expect(page).to have_notification_message("notice", "You are now logged out.")
    end
  end
end
