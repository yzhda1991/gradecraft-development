require "rails_spec_helper"

feature "copying a course" do
  context "as a professor" do
    let(:course) { create :course, name: "Course Name"}
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within("#mycourses") do
        click_link "Copy this Course"
      end

      expect(current_path).to eq course_path(Course.last)
      expect(page).to have_notification_message("notice", "Course Name successfully copied")
    end

  end
end
