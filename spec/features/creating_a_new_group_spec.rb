require "spec_helper"

feature "creating a new group" do
  context "as a professor" do
    let(:course) { build :course }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }
    let!(:assignment) { create :group_assignment, course: course, min_group_size: 2, max_group_size: 5 }
    let(:student_1) { build :user, first_name: "Hermione", last_name: "Granger"}
    let!(:course_membership_2) { create :course_membership, :student, user: student_1, course: course }
    let(:student_2) { build :user, first_name: "Ron", last_name: "Weasley"}
    let!(:course_membership_3) { create :course_membership, :student, user: student_2, course: course }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "unsuccessfully without group members" do
      within(".sidebar-container") do
        click_link "Groups"
      end

      expect(current_path).to eq groups_path

      within(".context_menu") do
        click_link "New Group"
      end

      expect(current_path).to eq new_group_path

      within(".pageContent") do
        fill_in "Name", with: "New Group Name"
        find(:css, "#group_assignment_ids_#{assignment.id}").set(true)
        click_button "Create Group"
      end

      expect(page).to have_notification_message("alert", "You don't have enough group members.")
    end

    scenario "unsuccessfully without an assignment" do
      within(".sidebar-container") do
        click_link "Groups"
      end

      expect(current_path).to eq groups_path

      within(".context_menu") do
        click_link "New Group"
      end

      expect(current_path).to eq new_group_path

      within(".pageContent") do
        fill_in "Name", with: "New Group Name"
        find(:css, "#group_assignment_ids_#{assignment.id}").set(false)
        click_button "Create Group"
      end

      expect(page).to have_notification_message("alert", "You need to check off which assignment your group will work on.")
    end
  end
end
