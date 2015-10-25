require "spec_helper"

feature "submitting an assignment", focus: true do
  let(:password) { "p@ssword" }

  context "as a student" do
    let(:course) { create :course }
    let(:assignment_type) {create :assignment_type, course: course}
    let(:assignment) {create :individual_assignment_with_submissions, assignment_type: assignment_type}
    let!(:course_membership) { create :student_course_membership, user: user, course: course }
    let(:user) { create :user, password: password }

    before { visit root_path }

    before(:each) do
      LoginPage.new(user).submit({ password: password })
    end

    scenario "successfully" do

      visit syllabus_path

      expect(page).to have_content assignment_type.name
    end

  end
  
end