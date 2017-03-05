require "spec_helper"

describe Assignments::StudentsController do
  let(:course) { build(:course) }
  let(:assignment) { create(:assignment, course: course) }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }

  describe "#grade" do

    context "as a professor" do
      before(:each) { login_user(professor) }

      it "creates the grade for the assignment and student if it doesn't exist" do
        post :grade, params: { assignment_id: assignment.id,
                               student_id: student.id }

        grade = Grade.unscoped.last
        expect(grade.assignment_id).to eq assignment.id
        expect(grade.student_id).to eq student.id
      end

      it "redirects to the edit grade view" do
        post :grade, params: { assignment_id: assignment.id,
                               student_id: student.id }

        expect(response).to redirect_to edit_grade_path(Grade.unscoped.last)
      end
    end

    context "as a student" do
      before(:each) { login_user(student) }

      it "redirects to the root" do
        post :grade, params: { assignment_id: assignment.id,
                               student_id: student.id }

        expect(response).to redirect_to root_path
      end
    end
  end
end
