feature "editing a team challenge grade" do
  context "as a professor" do
    let(:course) { build :course, has_team_challenges: true }
    let(:professor) { create :user }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let!(:challenge) { create :challenge, name: "Section Challenge Name", course: course }
    let!(:team) { create :team, name: "Section Name", course: course }
    let!(:challenge_grade) { create :challenge_grade, team: team, challenge: challenge, raw_points: 100 }

    before(:each) do
      login_as professor
      visit edit_challenge_grade_path(challenge_grade)
    end

    scenario "successfully" do
      within(".pageContent") do
        fill_in("challenge_grade_raw_points", with: 101)
        click_button "Update Grade"
      end

      expect(current_path).to eq challenge_path(challenge.id)
      expect(page).to have_notification_message("notice", "Section Name's Grade for Section Challenge Name Section Challenge successfully updated")
    end
  end
end
