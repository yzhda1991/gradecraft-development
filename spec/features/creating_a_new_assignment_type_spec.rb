require "spec_helper"

feature "creating a new assignment type" do
  context "as a professor" do
    let(:course) { build :course }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
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
      expect(current_path).to eq assignments_path
      
      #expect(page).to have_notification_message("success", "Assignment Type New Assignment Type Name successfully created")
    end
  end
end
