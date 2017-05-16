feature "grading a team challenge" do
  context "as a professor" do
    let(:course) { build :course, has_team_challenges: true }
    let(:professor) { create :user }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let!(:challenge) { create :challenge, name: "Section Challenge Name", course: course }
    let!(:team) { create :team, name: "Section Name", course: course }

    before(:each) do
      login_as professor
      visit challenges_path
    end

    scenario "successfully" do
      within(".pageContent") do
        click_link "Section Challenge Name"
      end

      within(".pageContent") do
        click_link "Grade"
      end

      within(".pageContent") do
        fill_in("challenge_grade_raw_points", with: 100)
        click_button "Submit Grade"
      end
      expect(page).to have_notification_message("notice", "Section Name's Grade for Section Challenge Name Section Challenge successfully graded")
    end
  end
end
