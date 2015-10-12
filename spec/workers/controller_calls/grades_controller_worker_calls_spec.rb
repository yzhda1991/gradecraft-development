require 'spec_helper'

RSpec.describe GradesController, type: :controller, background_job: true do
  include InQueueHelper
  let(:course) { create(:course_accepting_groups) }
  let(:assignment) { create(:assignment, course_id: course.id) }
  let(:job_attributes) {{grade_id: grade.id}} # for GradeUpdaterJob calls
  let(:grade) { create(:grade, course_id: course.id, student_id: student.id) }

  let(:student) { create(:user) }
  let(:enroll_student) { CourseMembership.create(user_id: student.id, course_id: course.id, role: "student") }
  let(:professor) { create(:user) }
  let(:enroll_professor) { CourseMembership.create(user_id: professor.id, course_id: course.id, role: "professor") }

  before(:each) { ResqueSpec.reset! }

  describe "#self_log" do
    let(:grade) { create(:grade, course_id: course.id, student_id: student.id) }
    let(:request_attrs) {{ id: assignment.id }}
    subject { get :self_log, request_attrs }

    before(:each) do
      enroll_student
      login_user(student)
      session[:course_id] = course.id
      allow(student).to receive(:grade_for_assignment).with(assignment) { grade }
    end

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
    let(:request_attrs) {{ assignment_id: assignment.id, format: :json }}
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

  describe "#update" do
    let(:professor) { create(:user) }
    let(:enroll_professor) { CourseMembership.create(course_id: course.id, user_id: professor.id, role: "professor") }
    let(:request_attrs) {{ assignment_id: assignment.id, grade: {raw_score: 50} }}
    subject { put :update, request_attrs }

    before(:each) do
      # stub away the current_student.present? call
      allow(controller).to receive_messages({
        current_student: student,
        extract_file_attributes_from_grade_params: true,
        add_grade_files_to_grade: true,
        sanitize_grade_params: true
      })
      allow(student).to receive(:grade_for_assignment).and_return grade
      enroll_professor
      login_user(professor)
      session[:course_id] = course.id
    end

    context "grade attributes are successfully updated" do
      before(:each) { allow(grade).to receive(:update_attributes) { true } }

      context "grade is released" do
        before(:each) { allow(grade).to receive(:is_released?) { true } }

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

      context "grade has not been released" do
        before(:each) { allow(grade).to receive(:is_released?) { false } }

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

    context "grade attributes fail to update" do
      before(:each) { allow(grade).to receive(:update_attributes) { false } }

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
