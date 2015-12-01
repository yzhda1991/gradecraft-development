require "rails_spec_helper"

feature "creating a new course" do
  context "as a professor" do
    let!(:course_membership) { create :professor_course_membership, user: user }
    let(:password) { "p@ssword" }
    let(:user) { create :user, password: password }

    before(:each) do
      login_as user, password
      visit dashboard_path
    end

    scenario "successfully" do
      within("#mycourses") do
        click_link "Create a New Course"
      end

      within(".pageContent") do
        fill_in "Course Title", with: "Course Name"
        fill_in "Course Number", with: "101"
        click_button "Create Course"
      end

      expect(current_path).to eq course_path(Course.last)
      expect(page).to have_notification_message('notice', 'Course Course Name successfully created')
    end
  end
end
