require "rails_spec_helper"

feature "creating a new group" do
  context "as a professor" do
    let(:course) { create :course }
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }
    let!(:assignment) { create :assignment, grade_scope: "Group", course: course }
    let(:student_1) { create :user, first_name: "Hermione", last_name: "Granger"}
    let!(:course_membership_2) { create :student_course_membership, user: student_1, course: course }
    let(:student_2) { create :user, first_name: "Ron", last_name: "Weasley"}
    let!(:course_membership_3) { create :student_course_membership, user: student_2, course: course }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "unsuccessfully without group members" do
      within(".sidebar-container") do
        click_link "groups"
      end

      expect(current_path).to eq groups_path

      within(".context_menu") do
        click_link "New group"
      end

      expect(current_path).to eq new_group_path

      within(".pageContent") do
        fill_in "Name", with: "New Group Name"
        find(:css, "#group_assignment_ids_#{assignment.id}").set(true)
        click_button "Create group"
      end

      expect(page).to have_notification_message('alert', "You don't have enough group members.")
    end
  end
end
