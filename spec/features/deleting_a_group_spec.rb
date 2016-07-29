require "rails_spec_helper"

feature "deleting a group" do
  context "as a professor" do
    let(:course) { create :course, has_team_challenges: true}
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }
    let!(:group) { create :group, name: "Group Name", course: course }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within(".sidebar-container") do
        click_link "Groups"
      end

      expect(current_path).to eq groups_path

      within(".pageContent") do
        click_link "Delete"
      end

      expect(page).to have_notification_message("success", "Group Name Group successfully deleted")
    end
  end
end
