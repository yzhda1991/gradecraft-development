require "rails_spec_helper"
require "set"

include ResqueJobSharedExamplesToolkit

RSpec.describe GradesController, type: :controller, background_job: true do
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

  context "triggering jobs as a student" do
    describe "#self_log" do

      before { allow_any_instance_of(Assignment).to receive(:student_logged?) { true } }
      let(:request_attrs) {{ id: assignment.id }}
      subject { get :self_log, request_attrs }
      before { enroll_and_login_student }
      before(:each) { cache_everything }

      it_behaves_like "a successful resque job", GradeUpdaterJob
    end
  end

  describe "triggering jobs as a professor" do
    before(:each) { enroll_and_login_professor }

    describe "#update" do
      let(:request_attrs) {{ assignment_id: assignment.id, grade: { raw_score: 50 } }}
      subject { put :update, request_attrs }

      before do
        allow(Grade).to receive(:find_or_create).and_return grade
      end

      context "grade attributes are successfully updated" do
        before { allow(grade).to receive(:update_attributes) { true } }

        context "grade is released" do
          let(:grade) { create(:released_grade, grade_attributes) }

          before do
            allow(grade).to receive(:is_released?) { true }
          end

          it_behaves_like "a successful resque job", GradeUpdaterJob
        end

        context "grade has not been released" do
          before { allow(grade).to receive(:is_released?) { false } }

          it_behaves_like "a failed resque job", GradeUpdaterJob
        end
      end

      context "grade attributes fail to update" do
        before { allow(grade).to receive(:update_attributes) { false } }

        it_behaves_like "a failed resque job", GradeUpdaterJob
      end
    end

    describe "actions that trigger multiple GradeUpdaterJob instances" do
      let(:student2) { create(:user) }
      let(:students) { [student, student2] }
      let(:grade2) { create(:grade, grade_attributes.merge(student_id: student2.id)) }
      let(:grades) { [grade, grade2] }
      let(:grade_ids) { [grade.id, grade2.id] }
      let(:job_attributes) {{ grade_ids: grade_ids }} # for GradeUpdaterJob calls

      # duplicate this

      describe "PUT #mass_update" do
        before { enroll_and_login_professor }
        let(:request_attrs) {{ id: assignment.id, assignment: {} }}
        subject { put :mass_update, request_attrs }

        before do
          allow(course).to receive_message_chain(:assignments, :find) { assignment }
          allow(controller).to receive(:mass_update_grade_ids) { grade_ids }
        end

        context "grade attributes are successfully updated" do
          let(:request_attrs) {{ assignment_id: assignment.id,
            id: assignment.id, assignment: {name: "Some Great Name"}}}
          before { allow(assignment).to receive_messages(update_attributes: true) }

          it_behaves_like "a batch of successful resque jobs", 2, GradeUpdaterJob
        end

        context "grade attributes fail to update" do
          # pass an invalid assignment name to fail the update
          # todo: FIX this, I have no idea why it won't stub
          let(:request_attrs) {{ id: assignment.id, assignment: { name: nil }}}
          before { allow(assignment).to receive_messages(update_attributes: false) }

          it_behaves_like "a failed resque job", GradeUpdaterJob
        end
      end

      describe "POST #upload" do
        subject { post :upload, request_attrs }
        before { enroll_and_login_professor }
        let(:file) { fixture_file "grades.csv", "text/csv" }
        let(:result_double) { double(:import_result) }

        context "params[:file] is present" do
          # only call the job if a file is present
          let(:request_attrs) {{
            id: assignment.id,
            file: file,
            assignment_id: assignment.id
          }}

          before do
            # establishing state for controller to trigger job
            allow(controller).to receive_message_chain(:current_course, :assignments, :find) { assignment }
            allow(course).to receive(:students) { students }
            allow(professor).to receive(:admin?) { true } # let's call the prof an admin for now
            # stub away before filters
            allow(request).to receive_message_chain(:format, :html?) { false } # increment_page_views
            allow(controller).to receive_message_chain(:current_student, :present?) { false } # get_course_scores
            # some more stubs
            allow(controller).to receive_message_chain(:current_course, :students) { students }
            allow(GradeImporter).to receive_message_chain(:new, :import) { result_double }
            allow(result_double).to receive(:successful).and_return(grades)
          end

          it_behaves_like "a batch of successful resque jobs", 2, GradeUpdaterJob
        end
      end

      describe "PUT #update_status" do
        subject { put :update_status, request_attrs }
        before { enroll_and_login_professor }

        context "params[:file] is present" do
          let(:request_attrs) {{ id: assignment.id, grade_ids: grade_ids }}
          before { allow(controller).to receive_messages(update_status_grade_ids: grade_ids) }
        end
      end

    end
  end

  def enroll_and_login_professor
    allow(controller).to receive_messages(current_student: student)
    enroll_professor
    login_user(professor)
    session[:course_id] = course.id
  end

  def enroll_and_login_student
    allow(controller).to receive_messages(current_student: student)
    enroll_student
    login_user(student)
    session[:course_id] = course.id
  end
end
