require "rails_spec_helper"

feature "editing an assignment type" do
  context "as a professor" do
    let(:course) { create :course, assignment_term: "Assignment"}
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }
    let!(:assignment_type) { create :assignment_type, name: "Assignment Type Name", course: course }

    before(:each) do
      login_as professor
      visit assignments_path
    end

    scenario "successfully" do
      within(".assignments") do
        click_link "[ Edit ]"
      end

      expect(current_path).to eq edit_assignment_type_path(assignment_type)

      within(".pageContent") do
        fill_in "Name", with: "Edited Assignment Type Name"
        click_button "Update Assignment type"
      end

      expect(page).to have_notification_message("success", "Assignment Type Edited Assignment Type Name successfully updated")
    end
  end
end
