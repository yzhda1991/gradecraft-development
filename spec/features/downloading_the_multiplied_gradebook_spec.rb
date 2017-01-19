require "rails_spec_helper"

feature "downloading multiplied gradebook file" do
  context "as a professor" do
    let(:course) { create :course, name: "Course Name", has_multipliers: true }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
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
        click_link "Multiplied Gradebook"
      end

      expect(page).to have_notification_message("notice", "Your request to export the multiplied gradebook for \"Course Name\" is currently being processed. We will email you the data shortly.")

    end
  end
end
