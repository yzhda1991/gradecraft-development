require "rails_spec_helper"

feature "creating a new assignment type" do
  context "as a professor" do
    let(:course) { create :course, name: "Course Name", assignment_term: "Assignment"}
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within(".sidebar-container") do
        click_link "assignment types"
      end

      within(".context_menu") do
        click_link "New assignment type"
      end

      expect(current_path).to eq new_assignment_type_path

      within(".pageContent") do
        fill_in "Name", with: "New Assignment Type Name"
        click_button "Create assignment type"
      end

      expect(page).to have_notification_message("success", "Assignment Type New Assignment Type Name successfully created")
    end
  end
end
