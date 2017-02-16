require "spec_helper"

feature "deleting an event" do
  context "as a professor" do
    let(:course) { build :course }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }
    let!(:event) { create :event, course: course, name: "Event Name", due_at: Date.today }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within(".sidebar-container") do
        click_link "Calendar Events"
      end

      expect(current_path).to eq events_path

      within(".pageContent") do
        click_link "Delete"
      end

      expect(page).to have_notification_message("notice", "Event Name successfully deleted")
    end
  end
end
