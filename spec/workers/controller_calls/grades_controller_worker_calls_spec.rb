require 'spec_helper'

RSpec.describe GradesController, type: :controller, background_job: true do
  include InQueueHelper
  let(:course) { create(:course_accepting_groups) }
  let(:student) { create(:user) }
  let(:assignment) { create(:assignment, course_id: course.id) }
  let(:job_attributes) {{grade_id: grade.id }}

  describe "#self_log" do
    let(:grade) { create(:grade, course_id: course.id, student_id: student.id) }

    before do
      enroll_student
      login_user(student)
      session[:course_id] = course.id
    end

    before(:each) do
      ResqueSpec.reset!
      allow(student).to receive(:grade_for_assignment).with(assignment) { grade }
    end

    let(:enroll_student) { CourseMembership.create(course_id: course.id, user_id: student.id, role: "student") }
    let(:request_attrs) {{ id: assignment.id }}
    subject { get :self_log, request_attrs }

    it "increases the queue size by one" do
      expect{ subject }.to change { queue(GradeUpdaterJob).size }.by(1)
    end

    it "queues the job" do
      subject
      expect(GradeUpdaterJob).to have_queued(job_attributes)
    end

    it "builds a new GradebookUpdaterJob" do
      subject
      expect(assigns(:grade_updater_job).class).to eq(GradeUpdaterJob)
    end
  end

  describe "#submit_rubric" do
    let(:professor) { create(:user) }
    let(:enroll_professor) { CourseMembership.create(course_id: course.id, user_id: professor.id, role: "professor") }
    let(:request_attrs) {{ assignment_id: assignment.id, format: :json }}
    let(:grade) { create(:grade, course_id: course.id, student_id: professor.id) }
    let(:null_methods) {[
      :delete_existing_rubric_grades,
      :create_rubric_grades, 
      :delete_existing_earned_badges_for_metrics,
    ]}
    let(:stub_null_methods) { null_methods.each {|method| allow(controller).to receive(method).and_return(nil) } }
    subject { put :submit_rubric, request_attrs }

    before(:each) do
      allow(Grade).to receive_message_chain(:where, :first) { grade }
      allow(controller).to receive_messages(current_student: student)
      stub_null_methods
      ResqueSpec.reset!
    end

    before do
      enroll_professor
      login_user(professor)
      session[:course_id] = course.id
    end

    context "grade is student visible" do
      before(:each) { allow(grade).to receive(:is_student_visible?) { true } }

      it "increases the queue size by one" do
        expect{ subject }.to change { queue(GradeUpdaterJob).size }.by(1)
      end

      it "queues the job" do
        subject
        expect(GradeUpdaterJob).to have_queued(job_attributes)
      end

      it "builds a new GradeUpdaterJob" do
        subject
        expect(assigns(:grade_updater_job).class).to eq(GradeUpdaterJob)
      end
    end

    context "grade is not student visible" do
      before(:each) { allow(grade).to receive(:is_student_visible?) { false } }

      it "doesn't change the queue size" do
        expect{ subject }.to change { queue(GradeUpdaterJob).size }.by(0)
      end

      it "doesn't queue the job" do
        subject
        expect(GradeUpdaterJob).not_to have_queued(job_attributes)
      end

      it "shouldn't build a new GradeUpdaterJob" do
        subject
        expect(assigns(:grade_updater_job)).to eq(nil)
      end
    end
  end
end
