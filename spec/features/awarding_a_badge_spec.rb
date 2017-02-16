require "spec_helper"

feature "awarding a badge" do
  context "as a professor" do
    let(:course) { build :course, has_badges: true }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }
    let!(:badge) { create :badge, name: "Fancy Badge", course: course}
    let(:student) { build :user, first_name: "Hermione", last_name: "Granger" }
    let!(:course_membership_2) { create :course_membership, :student, user: student, course: course }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within(".sidebar-container") do
        click_link "Badges"
      end

      expect(current_path).to eq badges_path

      within(".pageContent") do
        click_link "Award"
      end

      expect(current_path).to eq new_badge_earned_badge_path(badge)

      within(".pageContent") do
        select "Hermione Granger", from: "earned_badge_student_id"
        click_button "Award Badge"
      end
      expect(page).to have_notification_message("notice", "The Fancy Badge Badge was successfully awarded to Hermione Granger")
    end
  end
end
