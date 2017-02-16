require "spec_helper"

feature "editing a team" do
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
        click_link "Sections"
      end

      expect(current_path).to eq teams_path

      within(".pageContent") do
        click_link "Section Name"
      end

      expect(current_path).to eq team_path(team.id)

      within(".context_menu") do
        click_link "Edit"
      end

      within(".pageContent") do
        fill_in "Name", with: "Edited Section Name"
        click_button "Update Section"
      end
      
      expect(current_path).to eq team_path(team)
      
      expect(page).to have_content("Edited Section Name")
    end
  end
end
