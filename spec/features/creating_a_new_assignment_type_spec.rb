require "rails_spec_helper"

feature "creating a new assignment type" do
  context "as a professor" do
    let(:course) { create :course, name: "Course Name", assignment_term: "Assignment"}
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit assignments_path
    end

    scenario "successfully" do
      
      within(".box") do
        click_link "Add a New Assignment Type"
      end

      expect(current_path).to eq new_assignment_type_path

      within(".pageContent") do
        fill_in "Name", with: "New Assignment Type Name"
        click_button "Create Assignment type"
      end

      expect(page).to have_notification_message("success", "Assignment Type New Assignment Type Name successfully created")
    end
  end
end
