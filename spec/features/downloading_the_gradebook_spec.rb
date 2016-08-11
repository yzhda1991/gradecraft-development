require "rails_spec_helper"

feature "downloading gradebook file" do
  context "as a professor" do
    let(:course) { create :course, name: "Course Name" }
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do

      within(".sidebar-container") do
        click_link "Course Data Exports"
      end

      within(".pageContent") do
        click_link "Full Gradebook"
      end

      expect(page).to have_notification_message("notice", "Your request to export the gradebook for \"Course Name\" is currently being processed. We will email you the data shortly.")
    end
  end
end
