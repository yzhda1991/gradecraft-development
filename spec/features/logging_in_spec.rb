require "spec_helper"

feature "logging in" do
  let(:password) { "p@ssword" }

  context "as a student" do
    let!(:course_membership) { create :student_course_membership, user: user }
    let(:user) { create :user, password: password }

    scenario "logging in with password successfully" do
      visit root_path
      LoginPage.new(user).submit({password: password})

      expect(current_path).to eq syllabus_path
      within("header") do
        expect(page).to have_content user.display_name
      end
    end
  end
end
