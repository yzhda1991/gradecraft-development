require "rails_spec_helper"

feature "creating a new team" do
  context "as a professor" do
    let(:course) { create :course, has_teams: true }
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within(".sidebar-container") do
        click_link "Sections"
      end

      within(".context_menu") do
        click_link "New Section"
      end

      expect(current_path).to eq new_team_path

      within(".pageContent") do
        fill_in "Name", with: "New Section Name"
        click_button "Create Section"
      end
      
      expect(current_path).to eq team_path(Team.last)
      expect(page).to have_content("New Section Name")
    end
  end
end
