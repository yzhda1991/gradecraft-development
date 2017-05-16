feature "creating a new challenge" do
  context "as a professor" do
    let(:course) { build :course, has_team_challenges: true}
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit challenges_path
    end

    scenario "successfully" do
      within(".context_menu") do
        click_link "New Section Challenge"
      end

      expect(current_path).to eq new_challenge_path

      within(".pageContent") do
        fill_in "Name", with: "New Section Challenge Name"
        fill_in "challenge[full_points]", with: 100
        click_button "Create Section Challenge"
      end

      expect(page).to have_notification_message("notice", "Challenge New Section Challenge Name successfully created")
    end
  end
end
