require 'spec_helper'

describe GradesController do
  before(:all) do
    @course = create(:course)
    @assignment = create(:assignment, course: @course)

    @student = create(:user)
    @student.courses << @course
  end
  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
    end
    before (:each) do
      @grade = create(:grade)
      @assignment.grades << @grade
      login_user(@professor)
    end

    describe "GET show" do
      it "shows the grade" do
        get :show, { :id => @grade.id, :assignment_id => @assignment.id, :student_id => @student.id }
        allow(GradesController).to receive(:current_student).and_return(@student)
        expect(assigns(:assignment)).to eq(@assignment)
        expect(assigns(:title)).to eq("#{@student.name}'s Grade for #{@assignment.name}")
        expect(response).to render_template(:show)
      end
    end

    describe "GET edit" do
      it "shows the grade edit form" do
        get :edit, { :id => @grade.id, :assignment_id => @assignment.id, :student_id => @student.id }
        allow(GradesController).to receive(:current_student).and_return(@student)
        expect(assigns(:assignment)).to eq(@assignment)
        expect(assigns(:title)).to eq("Editing #{@student.name}'s Grade for #{@assignment.name}")
        expect(response).to render_template(:edit)
      end
    end

    describe "POST update" do
      it "updates the grade" do
        skip "implement"
        params = { raw_score: 1000, assignment_id: @assignment.id }
        post :update, { :id => @grade.id, :assignment_id => @assignment.id, :student_id => @student.id }, :grade => params
        @grade.reload
        expect(response).to redirect_to(assignment_path(@grade.assignment))
        expect(@grade.score).to eq(1000)
      end
    end

    describe "GET mass_edit" do
      it "assigns params" do
        get :mass_edit, :id => @assignment.id
        expect(assigns(:title)).to eq("Quick Grade #{@assignment.name}")
        expect(response).to render_template(:mass_edit)
      end
    end

    describe "PUT mass_update" do
      before(:each) do
        @grade_2 = create(:grade)
        @assignment.grades << @grade_2
      end

      let(:grades_attributes) do
        { "0" => { graded_by_id: @professor.id, instructor_modified: true,
                   student_id: @student.id, raw_score: 1000, status: "Graded", id: @grade_2.id }}
      end

      it "updates the grades for the specific assignment" do
        run_resque_inline do
          put :mass_update, id: @assignment.id, assignment: { grades_attributes: grades_attributes }
          expect(@grade_2.reload.raw_score).to eq 1000
        end
      end

      it "sends a notification to the student to inform them of a new grade" do
        pending "fix this later, needs to account for the job sending the mailer"
        run_resque_inline do
          expect { put :mass_update, id: @assignment.id, assignment: { grades_attributes: grades_attributes } }.to \
            change { ActionMailer::Base.deliveries.count }.by 1
        end
      end

      it "only sends notifications to the students if the grade changed" do
        @grade_2.update_attributes({ raw_score: 1000 })
        run_background_jobs_immediately do
          expect { put :mass_update, id: @assignment.id, assignment: { grades_attributes: grades_attributes } }.to_not \
            change { ActionMailer::Base.deliveries.count }
        end
      end
    end

    describe "GET group_edit" do
      it "assigns params" do
        group = create(:group)
        @assignment.groups << group
        group.students << @student
        get :group_edit, { :id => @assignment.id, :group_id => group.id}
        expect(assigns(:title)).to eq("Grading #{group.name}'s #{@assignment.name}")
        expect(response).to render_template(:group_edit)
      end
    end

    describe "GET edit_status" do
      it "displays the edit status page" do
        get :edit_status, {:grade_ids => [@grade.id], :id => @assignment.id}
        expect(assigns(:title)).to eq("#{@assignment.name} Grade Statuses")
        expect(response).to render_template(:edit_status)
      end
    end

    describe "GET import" do
      it "displays the import page" do
        get :import, { :id => @assignment.id}
        expect(assigns(:title)).to eq("Import Grades for #{@assignment.name}")
        expect(response).to render_template(:import)
      end
    end

    describe "POST upload" do
      render_views

      let(:file) { fixture_file "grades.csv", "text/csv" }

      it "renders the results from the import" do
        @student.reload.update_attribute :email, "robert@example.com"
        second_student = create(:user, username: "jimmy")
        second_student.courses << @course

        post :upload, id: @assignment.id, file: file
        expect(response).to render_template :import_results
        expect(response.body).to include "2 Grades Imported Successfully"
      end

      it "renders any errors that have occured" do
        post :upload, id: @assignment.id, file: file
        expect(response.body).to include "2 Grades Not Imported"
        expect(response.body).to include "Student not found in course"
      end
    end
  end

  context "as student" do
    before(:all) do
      @grade = create(:grade, student: @student)
      @assignment.grades << @grade
    end
    before (:each) { login_user(@student) }

    before do
      login_user(@student)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
      allow(controller).to receive(:current_student).and_return(@student)
    end

    describe "GET show" do
      it "shows the grade display" do
        get :show, {:grade_id => @grade.id, :assignment_id => @assignment.id}
        expect(response).to redirect_to(assignment_path(@assignment))
      end
    end

    describe "POST predict_score" do
      it "updates the predicted score for an assignment" do
        predicted_points = (@assignment.point_total * 0.75).to_i
        get :predict_score, { :id => @assignment.id, predicted_score: predicted_points, format: :json }
        @grade.reload
        expect(@grade.predicted_score).to eq(predicted_points)
        expect(JSON.parse(response.body)).to eq({"id" => @assignment.id, "points_earned" => predicted_points})
      end
    end

    describe "POST feedback_read" do
      it "marks the grade as read by the student" do
        post :feedback_read, id: @assignment.id, grade_id: @grade.id
        expect(response).to redirect_to assignment_path(@assignment)
        expect(@grade.reload).to be_feedback_read
      end
    end

    describe "POST self_log" do
      it "creates a maximum score by the student" do
        post :self_log, id: @assignment.id, present: "true"
        grade = @assignment.grades.last
        expect(grade.raw_score).to eq @assignment.point_total
      end

      context "with assignment levels" do
        it "creates a score for the student at the specified level" do
          post :self_log, id: @assignment.id, present: "true", grade: { raw_score: "10000" }
          grade = @assignment.grades.last
          expect(grade.raw_score).to eq 10000
        end
      end
    end

    describe "protected routes" do
      before(:all) do
        @group = create(:group)
        @assignment.groups << @group
      end

      describe "GET edit" do
        it "redirects to root path" do
          get :edit, {:grade_id => @grade.id, :assignment_id => @assignment.id}
          expect(response).to redirect_to(:root)
        end
      end

      describe "GET update" do
        it "redirects to root path" do
          get :update, {:grade_id => @grade.id, :assignment_id => @assignment.id}
          expect(response).to redirect_to(:root)
        end
      end

      describe "GET submit_rubric" do
        it "redirects to root path" do
          get :submit_rubric, {:grade_id => @grade.id, :assignment_id => @assignment.id}
          expect(response).to redirect_to(:root)
        end
      end

      describe "GET remove" do
        it "redirects to root path" do
          get :remove, { :id => @assignment.id, :grade_id => @grade.id}
          expect(response).to redirect_to(:root)
        end
      end

      describe "DELETE destroy" do
        it "redirects to root path" do
          delete :destroy, {:grade_id => @grade.id, :assignment_id => @assignment.id}
          expect(response).to redirect_to(:root)
        end
      end

      describe "GET mass_edit" do
        it "redirects to root path" do
          get :mass_edit, { :id => @assignment.id }
          expect(response).to redirect_to(:root)
        end
      end

      describe "GET mass_update" do
        it "redirects to root path" do
          post :mass_update, { :id => @assignment.id}
          expect(response).to redirect_to(:root)
        end
      end

      describe "GET group_edit" do
        it "redirects to root path" do
          get :group_edit, { :id => @assignment.id, :group_id => @group.id}
          expect(response).to redirect_to(:root)
        end
      end

      describe "GET group_update" do
        it "redirects to root path" do
          post :group_update, { :id => @assignment.id, :group_id => @group.id}
          expect(response).to redirect_to(:root)
        end
      end

      describe "GET edit_status" do
        it "redirects to root path" do
          get :edit_status, {:grade_ids => [@grade.id], :id => @assignment.id}
          expect(response).to redirect_to(:root)
        end
      end

      describe "POST update_status" do
        it "redirects to root path" do
          post :update_status, {:grade_ids => @grade.id, :id => @assignment.id}
          expect(response).to redirect_to(:root)
        end
      end

      describe "GET import" do
        it "redirects to root path" do
          get :import, { :id => @assignment.id}
          expect(response).to redirect_to(:root)
        end
      end

      describe "POST upload" do
        it "redirects to root path" do
          post :upload, { :id => @assignment.id}
          expect(response).to redirect_to(:root)
        end
      end
    end
  end
end
