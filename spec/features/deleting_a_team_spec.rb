require "spec_helper"

feature "deleting a team" do
  context "as a professor" do
    let(:course) { build :course, has_teams: true }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }
    let!(:team) { create :team, name: "Section Name", course: course }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within(".sidebar-container") do
        click_link "Section"
      end

      expect(current_path).to eq teams_path

      within(".pageContent") do
        click_link "Delete"
      end

      expect(page).to have_notification_message("notice", "Section Section Name successfully deleted")
    end
  end
end
