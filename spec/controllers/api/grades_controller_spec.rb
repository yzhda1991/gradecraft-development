require "rails_spec_helper"

describe API::GradesController do
  let(:world) { World.create.with(:course, :student, :assignment, :grade) }
  let(:professor) { create(:professor_course_membership, course: world.course).user }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "GET show" do
      it "returns a student's grade for the current assignment" do
        get :show, assignment_id: world.assignment.id, student_id: world.student.id, format: :json
        expect(assigns(:grade).id).to eq(world.grade.id)
        expect(response).to render_template(:show)
      end

      it "assigns all options when release necessary" do
        world.assignment.update_attributes release_necessary: true
        get :show, assignment_id: world.assignment.id, student_id: world.student.id, format: :json
        expect(assigns(:grade_status_options)).to eq(["In Progress", "Graded", "Released"])
      end

      it "assigns limited options when release not necessary" do
        get :show, assignment_id: world.assignment.id, student_id: world.student.id, format: :json
        expect(assigns(:grade_status_options)).to eq(["In Progress", "Graded"])
      end
    end

    describe "GET group_index" do
      before(:each) do
        world.create_group
        world.assignment.groups << world.group
        world.group.students.each do |student|
          world.create_grade(assignment_id: world.assignment.id, student_id: student.id)
        end
      end

      it "returns 400 error code with individual assignment" do
        world.assignment.update_attributes grade_scope: "Individual"
        get :group_index, assignment_id: world.assignment.id, group_id: world.group.id, format: :json
        expect(response.status).to be(400)
      end

      it "returns criterion_grades and student ids for a group" do
        world.assignment.update_attributes grade_scope: "Group"
        get :group_index, assignment_id: world.assignment.id, group_id: world.group.id, format: :json
        expect(assigns(:student_ids)).to eq(world.group.students.pluck(:id))
        expect(assigns(:grades).length).to eq(world.group.students.length)
        expect(response).to render_template(:group_index)
      end
    end
  end

  context "as student" do
    before(:each) { login_user(world.student) }

    describe "GET show" do
      it "is a protected route" do
        expect(get :show, assignment_id: world.assignment.id, student_id: world.student.id, format: :json).to redirect_to(:root)
      end
    end

    describe "GET group_index" do
      it "is a protected route" do
        expect(get :group_index, assignment_id: world.assignment.id, group_id: 1, format: :json).to redirect_to(:root)
      end
    end
  end
end
