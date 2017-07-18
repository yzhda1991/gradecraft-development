feature "creating a new team" do
  context "as a professor" do
    let(:course) { build :course, has_teams: true }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit teams_path
    end

    scenario "successfully" do
      within(".context-menu") do
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
