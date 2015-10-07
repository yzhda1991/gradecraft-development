require "spec_helper"

feature "logging in", focus: true do
  let(:password) { "p@ssword" }

  context "as a student" do
    let!(:course_membership) { create :student_course_membership, user: user }
    let(:user) { create :user, password: password }

    before { visit root_path }

    scenario "with a password successfully" do
      LoginPage.new(user).submit({ password: password })

      expect(current_path).to eq syllabus_path
      within("header") do
        expect(page).to have_content user.display_name
      end
    end

    scenario "with an invalid email and password combination" do
      LoginPage.new(user).submit({ password: "blah" })
      expect(current_path).to eq user_sessions_path
      expect(page).to have_error_message "Email or Password were invalid, login failed."
    end
  end

  context "as a professor" do
    let!(:course_membership) { create :professor_course_membership, user: user }
    let(:user) { create :user, password: password }

    before { visit root_path }

    scenario "with a password successfully" do
      LoginPage.new(user).submit({ password: password })

      expect(current_path).to eq analytics_top_10_path
      within("header") do
        expect(page).to have_content user.display_name
      end
    end
  end

  context "as a gsi" do
    let!(:course_membership) { create :staff_course_membership, user: user }
    let(:user) { create :user, password: password }

    before { visit root_path }

    scenario "with a password successfully" do
      LoginPage.new(user).submit({ password: password })

      expect(current_path).to eq analytics_top_10_path
      within("header") do
        expect(page).to have_content user.display_name
      end
    end
  end

  context "as an admin" do
    let!(:course_membership) { create :admin_course_membership, user: user }
    let(:user) { create :user, password: password }

    before { visit root_path }

    scenario "with a password successfully" do
      LoginPage.new(user).submit({ password: password })

      expect(current_path).to eq analytics_top_10_path
      within(".sidebar-container") do
        expect(page).to have_content "Search Courses"
      end
    end
  end
end
