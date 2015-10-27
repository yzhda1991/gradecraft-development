require 'rails_spec_helper'

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
        expect(assigns(:assignments)).to eq([@assignment])
        expect(response).to render_template(:index)
      end
    end

    describe "GET settings" do
      it "returns title and assignments" do
        get :settings
        # TODO: notice, lib/course_terms.rb downcases the term_for assignments
        expect(assigns(:title)).to eq("Review assignment Settings")
        # TODO: confirm multiple assignments are chronological and alphabetical
        expect(assigns(:assignments)).to eq([@assignment])
        expect(response).to render_template(:settings)
      end
    end

    describe "GET show" do
      it "returns the assignment show page"do
        get :show, :id => @assignment.id
        expect(response).to render_template(:show)
      end
    end

    describe "GET new" do
      it "assigns title and assignments" do
        get :new
        expect(assigns(:title)).to eq("Create a New assignment")
        expect(assigns(:assignment)).to be_a_new(Assignment)
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "assigns title and assignments" do
        get :edit, :id => @assignment.id
        expect(assigns(:title)).to eq("Editing #{@assignment.name}")
        expect(assigns(:assignment)).to eq(@assignment)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST copy" do
      it "duplicates an assignment" do
        post :copy, :id => @assignment.id
        expect expect(@course.assignments.count).to eq(2)
      end
    end

    describe "POST create" do
      it "creates the assignment with valid attributes"  do
        params = attributes_for(:assignment)
        params[:assignment_type_id] = @assignment_type
        expect{ post :create, :assignment => params }.to change(Assignment,:count).by(1)
      end

      it "manages file uploads" do
        Assignment.delete_all
        params = attributes_for(:assignment)
        params[:assignment_type_id] = @assignment_type
        params.merge! :assignment_files_attributes => {"0" => {"file" => [fixture_file('test_file.txt', 'txt')]}}
        post :create, :assignment => params
        assignment = Assignment.where(name: params[:name]).last
        expect expect(assignment.assignment_files.count).to eq(1)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, assignment: attributes_for(:assignment, name: nil) }.to_not change(Assignment,:count)
      end
    end

    describe "POST update" do
      it "updates the assignment" do
        params = { name: "new name" }
        post :update, id: @assignment.id, :assignment => params
        expect(response).to redirect_to(assignments_path)
        expect(@assignment.reload.name).to eq("new name")
      end

      it "manages file uploads" do
        params = {:assignment_files_attributes => {"0" => {"file" => [fixture_file('test_file.txt', 'txt')]}}}
        post :update, id: @assignment.id, :assignment => params
        expect expect(@assignment.assignment_files.count).to eq(1)
      end
    end

    describe "GET sort" do
      it "sorts the assignments by params" do
        second_assignment = create(:assignment, assignment_type: @assignment_type)
        @course.assignments << second_assignment
        params = [second_assignment.id, @assignment.id]
        post :sort, :assignment => params

        expect(@assignment.reload.position).to eq(2)
        expect(second_assignment.reload.position).to eq(1)
      end
    end

    describe "GET update_rubrics" do
      it "assigns true or false to assignment use_rubric" do
        @assignment.update(:use_rubric => false)
        post :update_rubrics, :id => @assignment, :use_rubric => true
        expect(@assignment.reload.use_rubric).to be_truthy
      end
    end

    describe "GET rubric_grades_review" do
      it "assigns attributes for display" do
        group = create(:group, course: @course)
        group.assignments << @assignment

        get :rubric_grades_review, :id => @assignment
        expect(assigns(:title)).to eq(@assignment.name)
        expect(assigns(:assignment)).to eq(@assignment)
        expect(assigns(:groups)).to eq([group])
        expect(response).to render_template(:rubric_grades_review)
      end

      it "assigns the rubric as rubric" do
        rubric = create(:rubric_with_metrics, assignment: @assignment)
        get :rubric_grades_review, :id => @assignment.id
        expect(assigns(:rubric)).to eq(rubric)
      end

      it "assigns assignment score levels ordered by value" do
        assignment_score_level_second = create(:assignment_score_level, assignment: @assignment, value: "1000")
        assignment_score_level_first = create(:assignment_score_level, assignment: @assignment, value: "100")
        get :rubric_grades_review, :id => @assignment.id
        expect(assigns(:assignment_score_levels)).to eq([assignment_score_level_first,assignment_score_level_second])
      end

      it "assigns student ids" do
        get :rubric_grades_review, :id => @assignment.id
        expect(assigns(:course_student_ids)).to eq([@student.id])
      end

      describe "with team id in params" do
        it "assigns team and students for team" do
          # we verify only students on team assigned as @students
          other_student = create(:user)
          other_student.courses << @course

          team = create(:team, course: @course)
          team.students << @student

          get :rubric_grades_review, {:id => @assignment.id, :team_id => team.id}
          expect(assigns(:team)).to eq(team)
          expect(assigns(:students)).to eq([@student])
        end
      end

      describe "with no team id in params" do
        it "assigns all students if no team supplied" do
          # we verify non-team members also assigned as @students
          other_student = create(:user)
          other_student.courses << @course

          team = create(:team, course: @course)
          team.students << @student

          get :rubric_grades_review, :id => @assignment.id
          expect(assigns(:students)).to include(@student)
          expect(assigns(:students)).to include(other_student)
        end
      end
    end

    describe "GET predictor_data" do
      context "with a student id" do
        it "assigns the assignments with no call to update" do
          get :predictor_data, format: :json, :id => @student.id
          expect(assigns(:student)).to eq(@student)
          #expect(assigns(:assignments)[0].attributes.length).to eq(predictor_assignment_attributes.length)
          predictor_assignment_attributes().each do |attr|
            expect(assigns(:assignments)[0][attr]).to eq(@assignment[attr])
          end
          expect(assigns(:update_assignments)).to be_falsy
          expect(response).to render_template(:predictor_data)
        end
      end

      context "with no student" do
        it "assigns student as null student and no call to update" do
          get :predictor_data, format: :json
          expect(assigns(:student).class).to eq(NullStudent)
          expect(assigns(:update_assignments)).to be_falsy
        end
      end
    end

    describe "GET destroy" do
      it "destroys the assignment" do
        expect{ get :destroy, :id => @assignment }.to change(Assignment,:count).by(-1)
      end
    end

    describe "GET grade_import" do
      context "with CSV format" do
        it "returns sample csv data" do
          get :grade_import, :id => @assignment, :format => :csv
          expect(response.body).to include("First Name,Last Name,Email,Score,Feedback")
        end
      end
    end

    describe "GET export_grades" do
      context "with CSV format" do
        it "returns sample csv data" do
          grade = create(:grade, assignment: @assignment, student: @student, feedback: "good jorb!")
          submission = create(:submission, grade: grade, student: @student, assignment: @assignment)
          get :export_grades, :id => @assignment, :format => :csv
          expect(response.body).to include("First Name,Last Name,Uniqname,Score,Raw Score,Statement,Feedback")
        end
      end
    end

    describe "GET export_submissions" do
      context "with ZIP format" do
        it "returns a zip directory" do
          get :export_submissions, :id => @assignment, :format => :zip
          expect(response.content_type).to eq("application/zip")
        end
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
        get :show, :id => @assignment.id
        expect(grade.reload).to be_feedback_reviewed
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
        get :predictor_data, format: :json, :id => @student.id
        expect(assigns(:student)).to eq(@student)
        # expect(assigns(:assignments)[0].attributes.length).to eq(predictor_assignment_attributes.length)
        predictor_assignment_attributes().each do |attr|
          expect(assigns(:assignments)[0][attr]).to eq(@assignment[attr])
        end
        expect(assigns(:update_assignments)).to be_truthy
        expect(response).to render_template(:predictor_data)
      end

      it "includes the student's grade with score for assignment when released" do
        grade = create(:scored_grade, student: @student, assignment: @assignment, course_id: @course.id)
        get :predictor_data, format: :json, :id => @student.id
        [
          :assignment_id,
          :final_score,
          :id,
          :predicted_score,
          :pass_fail_status,
          :status,
          :student_id,
          :raw_score,
          :score
        ].each do |attr|
           expect(assigns(:grades)[0][attr]).to eq(grade[attr])
        end
        expect(assigns(:assignments)[0].current_student_grade).to eq({ id: grade.id, pass_fail_status: nil, score: grade.score, predicted_score: grade.predicted_score })
      end

      it "includes student grade with no score if not released" do
        grade = create(:unreleased_grade, student: @student, assignment: @assignment, course_id: @course.id)
        get :predictor_data, format: :json, :id => @student.id
        expect(assigns(:assignments)[0].current_student_grade[:score]).to eq(nil)
      end

      it "assigns data for displaying student grading distribution" do
        skip "need to create a scored grade"
        ungraded_submission = create(:submission, assignment: @assignment)
        student_submission = create(:graded_submission, assignment: @assignment, student: @student)
        @assignment.submissions << [student_submission, ungraded_submission]
        get :show, :id => @assignment.id
        expect(assigns(:submissions_count)).to eq(2)
        expect(assigns(:ungraded_submissions_count)).to eq(1)
        expect(assigns(:ungraded_percentage)).to eq(1/2)
        expect(assigns(:graded_count)).to eq(1)
      end

      it "assigns rubric grades" do
        skip "implement"
        rubric = create(:rubric_with_metrics, assignment: @assignment)
        # TODO: Test for this line:
        # @rubric_grades = RubricGrade.joins("left outer join submissions on submissions.id = rubric_grades.submission_id").where(student_id: current_user[:id]).where(assignment_id: params[:id])
        get :show, :id => @assignment.id
        expect(assigns(:rubric_grades)).to eq("?")
      end

      it "includes pass/fail status for released pass/fail grades" do
        grade = create(:scored_grade, student: @student, assignment: @assignment, course_id: @course.id, pass_fail_status: "Pass")
        get :predictor_data, format: :json, :id => @student.id
        expect(assigns(:assignments)[0].current_student_grade[:pass_fail_status]).to eq("Pass")
      end

      it "includes student grade with no pass fail status if not released" do
        grade = create(:unreleased_grade, student: @student, assignment: @assignment, course_id: @course.id, pass_fail_status: "Pass")
        get :predictor_data, format: :json, :id => @student.id
        expect(assigns(:assignments)[0].current_student_grade[:pass_fail_status]).to be_nil
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
        :destroy,
        :export_grades,
        :grade_import,
        :update_rubrics,
        :rubric_grades_review

      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, {:id => "1"}).to redirect_to(:root)
        end
      end
    end
  end
end


# helper methods:

def predictor_assignment_attributes
  [
    :accepts_resubmissions_until,
    :accepts_submissions,
    :accepts_submissions_until,
    :assignment_type_id,
    :course_id,
    :description,
    :due_at,
    :grade_scope,
    :id,
    :include_in_predictor,
    :name,
    :open_at,
    :pass_fail,
    :point_total,
    :points_predictor_display,
    :position,
    :release_necessary,
    :required,
    :resubmissions_allowed,
    :student_logged,
    :thumbnail,
    :use_rubric,
    :visible,
    :visible_when_locked
  ]
end

