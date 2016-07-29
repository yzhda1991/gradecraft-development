require "rails_spec_helper"

feature "grading a team challenge" do
  context "as a professor" do
    let(:course) { create :course, has_team_challenges: true }
    let(:professor) { create :user }
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let!(:challenge) { create :challenge, name: "Team Challenge Name", course: course }
    let!(:team) { create :team, name: "Team Name", course: course }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within(".sidebar-container") do
        click_link "Team Challenges"
      end

      expect(current_path).to eq challenges_path

      within(".pageContent") do
        click_link "Team Challenge Name"
      end

      expect(current_path).to eq challenge_path(challenge.id)

      within(".pageContent") do
        click_link "Grade"
      end

      expect(current_path).to eq new_challenge_challenge_grade_path(challenge.id)

      within(".pageContent") do
        fill_in("challenge_grade_score", with: 100)
        click_button "Submit Grade"
      end
      expect(page).to have_notification_message("notice", "Team Name's Grade for Team Challenge Name Team Challenge successfully graded")
    end
  end
end
