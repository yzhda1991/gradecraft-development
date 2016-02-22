require 'rails_spec_helper'
require "set"

include ResqueJobSharedExamplesToolkit

RSpec.describe API::CriterionGradesController, type: :controller, background_job: true do
  include InQueueHelper
  let(:course) { create(:course_accepting_groups) }
  let(:assignment) { create(:assignment, course_id: course.id) }
  let(:job_attributes) {{ grade_id: grade.id }} # for GradeUpdaterJob calls
  let(:grade_attributes) {{ course_id: course.id, student_id: student.id, assignment_id: assignment.id }}
  let(:grade) { create(:grade, grade_attributes) }
  let(:cache_everything) { course; assignment; grade; student; professor }

  let(:student) { create(:user) }
  let(:enroll_student) { CourseMembership.create(user_id: student.id, course_id: course.id, role: "student") }
  let(:professor) { create(:user) }
  let(:enroll_professor) { CourseMembership.create(user_id: professor.id, course_id: course.id, role: "professor") }

  before(:each) { ResqueSpec.reset! }

  describe "triggering jobs as a professor" do
    before(:each) { enroll_and_login_professor }

    describe "#submit_rubric" do
      skip "moved to api call, does this have to be run in the context of the GradesController?"
      let(:request_attrs) {{ student_id: student.id, assignment_id: assignment.id, criterion_grades: [], grade: { status: "", feedback: "" }, format: :json }}
      subject { put :update, request_attrs }

      before do
        allow(Grade).to receive_message_chain(:where, :first) { grade }
      end

      context "grade is student visible" do
        before { allow(grade).to receive(:is_student_visible?) { true } }

        it_behaves_like "a successful resque job", GradeUpdaterJob
      end

      context "grade is not student visible" do
        before { allow(grade).to receive(:is_student_visible?) { false } }

        it_behaves_like "a failed resque job", GradeUpdaterJob
      end
    end
  end

  def enroll_and_login_professor
    enroll_professor
    login_user(professor)
    session[:course_id] = course.id
  end
end
