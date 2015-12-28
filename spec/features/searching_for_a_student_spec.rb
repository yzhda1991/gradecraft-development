require "rails_spec_helper"

feature "searching for a student" do
  context "as a professor" do
    let(:course) { create :course}
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }
    let(:student) { create :user, first_name: "Hermione", last_name: "Granger" }
    let!(:course_membership_2) { create :student_course_membership, user: student, course: course }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      pending "can't find link"
      within(".sidebar-container") do
        fill_in("student-search", with: "Hermione")
        find_link("Hermione Granger", :visible=> false).click
      end

      expect(current_path).to eq student_path(student.id)
      expect(page).to have_content student.name
    end

  end
end
