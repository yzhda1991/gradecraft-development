require "rails_spec_helper"

feature "editing an assignment type", focus: true do
  context "as a professor" do
    let(:course) { create :course, assignment_term: "Assignment"}
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }
    let!(:assignment_type) { create :assignment_type, name: "Assignment Type Name", course: course }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within(".sidebar-container") do
        click_link "Assignment types"
      end

      expect(current_path).to eq assignment_types_path

      within(".pageContent") do
        click_link "Assignment Type Name"
      end

      expect(current_path).to eq assignment_type_path(assignment_type.id)

      within(".context_menu") do
        click_link "Edit"
      end

      within(".pageContent") do
        fill_in "Name", with: "Edited Assignment Type Name"
        click_button "Update Assignment type"
      end

      expect(page).to have_notification_message("success", "Assignment Type Edited Assignment Type Name successfully updated")
    end
  end
end
