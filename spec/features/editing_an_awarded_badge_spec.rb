require "rails_spec_helper"

feature "editing an awarded a badge" do
  context "as a professor" do
    let(:course) { create :course, badge_setting: true }
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }
    let!(:badge) { create :badge, name: "Fancy Badge", course: course}
    let(:student) { create :user, first_name: "Hermione", last_name: "Granger" }
    let(:student_2) { create :user, first_name: "Ron", last_name: "Weasley" }
    let!(:course_membership_2) { create :student_course_membership, user: student, course: course }
    let!(:course_membership_3) { create :student_course_membership, user: student_2, course: course }
    let!(:earned_badge) { create :earned_badge, badge: badge, student: student}

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within(".sidebar-container") do
        click_link "badges"
      end

      expect(current_path).to eq badges_path

      within(".pageContent") do
        click_link "Fancy Badge"
      end

      expect(current_path).to eq badge_path(badge.id)

      within(".pageContent") do
        click_link "Edit"
      end

      expect(current_path).to eq edit_badge_earned_badge_path(badge, earned_badge)

      within(".pageContent") do
        click_button "Update badge"
      end

      expect(current_path).to eq badge_path(badge.id)

      expect(page).to have_notification_message('notice', "Hermione Granger's Fancy Badge badge was successfully updated")
    end
  end
end
