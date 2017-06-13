RSpec.describe GradesController, type: :controller, background_job: true do
  include InQueueHelper

  let(:course) { create(:course) }
  let(:assignment) { create(:assignment, course_id: course.id) }
  let(:job_attributes) {{ grade_id: grade.id }} # for GradeUpdaterJob calls
  let(:grade_attributes) {{ course_id: course.id, student_id: student.id, assignment_id: assignment.id }}
  let(:grade) { create(:grade, grade_attributes) }

  let(:student) { create(:user) }
  let(:professor) { create(:user) }
  let(:enroll_professor) { create(:course_membership, :professor, user_id: professor.id, course_id: course.id) }

  before(:each) { ResqueSpec.reset! }

  describe "triggering jobs as a professor" do
    before(:each) { enroll_and_login_professor }

    describe "actions that trigger multiple GradeUpdaterJob instances" do
      let(:student2) { create(:user) }
      let(:students) { [student, student2] }
      let(:grade2) { create(:grade, grade_attributes.merge(student_id: student2.id)) }
      let(:grades) { [grade, grade2] }
      let(:grade_ids) { [grade.id, grade2.id] }

      describe "PUT #update_status" do
        subject { put :update_status, params: request_attrs }
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
end
