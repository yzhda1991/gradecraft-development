require "rails_spec_helper"

feature "viewing submissions" do
  context "as a student" do
    let!(:submission) do
      create :submission, course: membership.course, assignment: assignment, student: student
    end

    let(:assignment) { create :assignment, accepts_submissions: true, course: membership.course }
    let(:membership) { create :student_course_membership, user: student }
    let(:student) { create :user }

    before do
      login_as student
      visit assignment_path assignment
    end

    scenario "allows an editable submission if it's before the due date" do
      expect(find_link("Edit My Submission")).to be_visible
    end
  end
end
