require "rails_spec_helper"

feature "grading an individual assignment" do
  context "as a professor" do
    let(:course) { build :course }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }
    let!(:assignment_type) { create :assignment_type, name: "Assignment Type Name", course: course }
    let!(:assignment) { create :assignment, name: "Assignment Name", course: course, assignment_type: assignment_type }
    let(:student) { build :user, first_name: "Hermione", last_name: "Granger" }
    let!(:course_membership_2) { create :course_membership, :student, user: student, course: course }
    let!(:grade) { create :grade, assignment: assignment, student: student }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within(".sidebar-container") do
        click_link "Assignments"
      end

      expect(current_path).to eq assignments_path

      within(".pageContent") do
        find(".assignment-type-name").click
        click_link "Assignment Name"
      end

      expect(current_path).to eq assignment_path(assignment.id)

      within(".pageContent") do
        click_link "Grade"
      end

      expect(current_path).to eq edit_grade_path(grade)

      within(".pageContent") do
        fill_in("grade-raw-points", with: 100)
        click_button "Submit Grade"
      end
      expect(page).to have_notification_message("notice", "Hermione Granger's Assignment Name was successfully updated")
    end
  end
end
