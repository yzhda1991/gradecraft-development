require "rails_spec_helper"

describe AssignmentsController do
  before(:all) do
    @course = create(:course)
    @student = create(:user)
    @student.courses << @course
  end
  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as a professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
      @assignment_type = create(:assignment_type, course: @course)
    end

    before(:each) do
      @assignment = create(:assignment, assignment_type: @assignment_type, course: @course)
      login_user(@professor)
    end

    describe "GET index" do
      it "returns assignments for the current course" do
        get :index
        expect(assigns(:title)).to eq("assignments")
        expect(assigns(:assignment_types)).to eq([@assignment_type])
        expect(response).to render_template(:index)
      end
    end

    describe "GET settings" do
      it "returns title and assignments" do
        get :settings
        # TODO: notice, lib/course_terms.rb downcases the term_for assignments
        expect(assigns(:title)).to eq("Review assignment Settings")
        # TODO: confirm multiple assignments are chronological and alphabetical
        expect(assigns(:assignment_types)).to eq([@assignment_type])
        expect(response).to render_template(:settings)
      end
    end

    describe "GET show" do
      it "returns the assignment show page" do
        get :show, id: @assignment.id
        expect(response).to render_template(:show)
      end
    end

    describe "POST copy" do
      before(:each) do
        Assignment.delete_all
        @assignment =
          create(:assignment, assignment_type: @assignment_type, course: @course)
      end

      it "duplicates an assignment" do
        post :copy, id: @assignment.id
        expect expect(@course.assignments.count).to eq(2)
      end

      it "duplicates score levels" do
        @assignment.assignment_score_levels.create(name: "Level 1", value: 10_000)
        post :copy, id: @assignment.id
        duplicated = Assignment.last
        expect(duplicated.id).to_not eq @assignment.id
        expect(duplicated.assignment_score_levels.first.name).to eq "Level 1"
        expect(duplicated.assignment_score_levels.first.value).to eq 10_000
      end

      it "duplicates rubrics" do
        @assignment.create_rubric
        @assignment.rubric.criteria.create name: "Rubric 1", max_points: 10_000, order: 1
        @assignment.rubric.criteria.first.levels.first.badges.create! name: "Blah", course: @course
        post :copy, id: @assignment.id
        duplicated = Assignment.last
        expect(duplicated.rubric).to_not be_nil
        expect(duplicated.rubric.criteria.first.name).to eq "Rubric 1"
        expect(duplicated.rubric.criteria.first.levels.first.name).to eq "Full Credit"
        expect(duplicated.rubric.criteria.first.levels.first.level_badges.count).to \
          eq 1
      end

      it "redirects to the duplicated assignment" do
        post :copy, id: @assignment.id
        duplicated = Assignment.last
        expect(response).to redirect_to(assignment_path(duplicated))
      end
    end

    describe "POST create" do
      it "creates the assignment with valid attributes"  do
        params = attributes_for(:assignment)
        params[:assignment_type_id] = @assignment_type
        expect{ post :create, assignment: params }.to change(Assignment,:count).by(1)
      end

      it "manages file uploads" do
        Assignment.delete_all
        params = attributes_for(:assignment)
        params[:assignment_type_id] = @assignment_type
        params.merge! assignment_files_attributes: {"0" => {"file" => [fixture_file("test_file.txt", "txt")]}}
        post :create, assignment: params
        assignment = Assignment.where(name: params[:name]).last
        expect expect(assignment.assignment_files.count).to eq(1)
        expect expect(assignment.assignment_files[0].filename).to eq("test_file.txt")
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, assignment: attributes_for(:assignment, name: nil) }.to_not change(Assignment,:count)
      end
    end

    describe "POST update" do
      it "updates the assignment" do
        params = { name: "new name" }
        post :update, id: @assignment.id, assignment: params
        expect(response).to redirect_to(assignments_path)
        expect(@assignment.reload.name).to eq("new name")
      end

      it "updates the usage of rubrics" do
        @assignment.update(use_rubric: false)
        post :update, id: @assignment.id, assignment: { use_rubric: true },
          format: :json
        expect(@assignment.reload.use_rubric).to eq true
      end

      it "renders the template again if there are validation errors" do
        post :update, id: @assignment.id, assignment: { name: "" }
        expect(response).to render_template(:edit)
      end

      it "manages file uploads" do
        params = {assignment_files_attributes: {"0" => {"file" => [fixture_file("test_file.txt", "txt")]}}}
        post :update, id: @assignment.id, assignment: params
        expect expect(@assignment.assignment_files.count).to eq(1)
      end
    end

    describe "POST sort" do
      it "sorts the assignments by params" do
        second_assignment = create(:assignment, assignment_type: @assignment_type)
        @course.assignments << second_assignment

        post :sort, assignment: [second_assignment.id, @assignment.id]

        expect(@assignment.reload.position).to eq(2)
        expect(second_assignment.reload.position).to eq(1)
      end
    end

    describe "GET predictor_data" do
      context "with a student id" do
        it "assigns the assignments with no call to update" do
          get :predictor_data, format: :json, id: @student.id
          expect(assigns(:assignments).current_user).to eq(@professor)
          expect(assigns(:assignments).student).to eq(@student)
          predictor_assignment_attributes.each do |attr|
            expect(assigns(:assignments).assignments[0][attr]).to \
              eq(@assignment[attr])
          end
          expect(assigns(:assignments).permission_to_update?).to be_falsey
          expect(response).to render_template(:predictor_data)
        end

        it "assigns a unreleased grade for the assignment with no score data" do
          grade = create(:unreleased_grade, student: @student, assignment: @assignment, predicted_score: 500)
          get :predictor_data, format: :json, id: @student.id
          expect(assigns(:assignments).current_user).to eq(@professor)
          expect(assigns(:assignments).student).to eq(@student)
          assigns(:assignments)[0].grade.attributes.tap do |assigned_grade|
            expect(assigned_grade[:id]).to eq(grade.id)
            expect(assigned_grade[:final_points]).to eq(nil)
            expect(assigned_grade[:score]).to eq(nil)
            expect(assigned_grade[:predicted_score]).to eq(0)
          end
        end

        it "assigns a released grade for the assignment with no predicted score" do
          grade = create(:released_grade, student: @student, assignment: @assignment, predicted_score: 500)
          get :predictor_data, format: :json, id: @student.id
          expect(assigns(:assignments).current_user).to eq(@professor)
          expect(assigns(:assignments).student).to eq(@student)
          assigns(:assignments)[0].grade.attributes.tap do |assigned_grade|
            expect(assigned_grade[:id]).to eq(grade.id)
            expect(assigned_grade[:final_points]).to eq(grade.raw_score)
            expect(assigned_grade[:score]).to eq(grade.score)
            expect(assigned_grade[:predicted_score]).to eq(0)
          end
        end
      end

      context "with no student" do
        it "assigns student as null student and no call to update" do
          get :predictor_data, format: :json
          expect(assigns(:assignments).current_user).to eq(@professor)
          expect(assigns(:assignments).student.class).to eq(NullStudent)
          expect(assigns(:assignments).permission_to_update?).to be_falsey
        end
      end
    end

    describe "GET export_structure" do
      it "retrieves the export_structure download" do
        get :export_structure, format: :csv
        expect(response.body).to include("Assignment ID,Name,Point Total,Description,Open At,Due At,Accept Until")
      end
    end

    describe "GET destroy" do
      it "destroys the assignment" do
        expect{ get :destroy, id: @assignment }.to change(Assignment,:count).by(-1)
      end
    end
  end

  context "as a student" do
    before(:each) { login_user(@student) }

    describe "GET index" do
      it "redirects to syllabus path" do
        expect(get :index).to redirect_to("/syllabus")
      end
    end

    describe "GET show" do
      before do
        assignment_type = create(:assignment_type, course: @course)
        @assignment = create(:assignment)
        @course.assignments << @assignment
      end

      it "marks the grade as reviewed" do
        grade = create :grade, assignment: @assignment, student: @student, status: "Graded"
        get :show, id: @assignment.id
        expect(grade.reload).to be_feedback_reviewed
      end

      it "redirects to the assignments path of the assignment does not exist for the current course" do
        another_assignment = create(:assignment)
        get :show, id: another_assignment.id
        expect(response).to redirect_to assignments_path
      end
    end

    describe "GET predictor_data" do
      before do
        assignment_type = create(:assignment_type, course: @course)
        @assignment = create(:assignment)
        @course.assignments << @assignment
        allow(controller).to receive(:current_course).and_return(@course)
      end

      it "assigns the assignments with the call to update" do
        get :predictor_data, format: :json, id: @student.id
        expect(assigns(:assignments).current_user).to eq(@student)
        expect(assigns(:assignments).student).to eq(@student)
        predictor_assignment_attributes.each do |attr|
          expect(assigns(:assignments).assignments[0][attr]).to \
            eq(@assignment[attr])
        end
        expect(assigns(:assignments).permission_to_update?).to be_truthy
        expect(response).to render_template(:predictor_data)
      end

      it "includes student grade with no score if not released" do
        grade = create(:unreleased_grade, student: @student, assignment: @assignment, course_id: @course.id)
        get :predictor_data, format: :json, id: @student.id
        expect(assigns(:assignments)[0].grade.attributes[:score]).to eq(nil)
        expect(assigns(:assignments)[0].grade.attributes[:final_points]).to eq(nil)
      end

      it "assigns a unreleased grade for the assignment with only predicted score data" do
        grade = create(:unreleased_grade, student: @student, assignment: @assignment, predicted_score: 500)
        get :predictor_data, format: :json, id: @student.id
        expect(assigns(:assignments).current_user).to eq(@student)
        expect(assigns(:assignments).student).to eq(@student)
        assigns(:assignments)[0].grade.attributes.tap do |assigned_grade|
          expect(assigned_grade[:id]).to eq(grade.id)
          expect(assigned_grade[:final_points]).to eq(nil)
          expect(assigned_grade[:score]).to eq(nil)
          expect(assigned_grade[:predicted_score]).to eq(500)
        end
      end

      it "assigns a released grade for the assignment with all score data" do
        grade = create(:released_grade, student: @student, assignment: @assignment, predicted_score: 500)
        get :predictor_data, format: :json, id: @student.id
        expect(assigns(:assignments).current_user).to eq(@student)
        expect(assigns(:assignments).student).to eq(@student)
        assigns(:assignments)[0].grade.attributes.tap do |assigned_grade|
          expect(assigned_grade[:id]).to eq(grade.id)
          expect(assigned_grade[:final_points]).to eq(grade.raw_score)
          expect(assigned_grade[:score]).to eq(grade.score)
          expect(assigned_grade[:predicted_score]).to eq(500)
        end
      end

      it "assigns data for displaying student grading distribution" do
        skip "need to create a scored grade"
        ungraded_submission = create(:submission, assignment: @assignment)
        student_submission = create(:graded_submission, assignment: @assignment, student: @student)
        @assignment.submissions << [student_submission, ungraded_submission]
        get :show, id: @assignment.id
        expect(assigns(:submissions_count)).to eq(2)
        expect(assigns(:ungraded_submissions_count)).to eq(1)
        expect(assigns(:ungraded_percentage)).to eq(1/2)
        expect(assigns(:graded_count)).to eq(1)
      end

      it "assigns rubric grades" do
        skip "implement"
        rubric = create(:rubric_with_criteria, assignment: @assignment)
        # TODO: Test for this line:
        # @criterion_grades = CriterionGrade.joins("left outer join submissions on submissions.id = criterion_grades.submission_id").where(student_id: current_user[:id]).where(assignment_id: params[:id])
        get :show, id: @assignment.id
        expect(assigns(:criterion_grades)).to eq("?")
      end

      it "includes pass/fail status for released pass/fail grades" do
        grade = create(:released_grade, student: @student, assignment: @assignment, course_id: @course.id, pass_fail_status: "Pass")
        get :predictor_data, format: :json, id: @student.id
        expect(assigns(:assignments)[0].grade.pass_fail_status).to eq("Pass")
      end

      it "includes student grade with no pass fail status if not released" do
        grade = create(:unreleased_grade, student: @student, assignment: @assignment, course_id: @course.id, pass_fail_status: "Pass")
        get :predictor_data, format: :json, id: @student.id
        expect(assigns(:assignments)[0].grade.pass_fail_status).to be_nil
      end
    end

    describe "protected routes" do
      [
        :new,
        :copy,
        :create,
        :sort

      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route).to redirect_to(:root)
        end
      end
    end

    describe "protected routes requiring id in params" do
      [
        :edit,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, {id: "1"}).to redirect_to(:root)
        end
      end
    end
  end
end

def predictor_assignment_attributes
  [
    :accepts_submissions,
    :accepts_submissions_until,
    :assignment_type_id,
    :description,
    :due_at,
    :grade_scope,
    :id,
    :include_in_predictor,
    :name,
    :pass_fail,
    :point_total,
    :points_predictor_display,
    :position,
    :required,
    :use_rubric,
    :visible,
    :visible_when_locked
  ]
end
