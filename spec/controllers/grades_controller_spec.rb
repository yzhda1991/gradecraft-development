require 'spec_helper'

describe GradesController do

  context "as professor" do
    before do
      @course = create(:course_accepting_groups)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @assignment_type = create(:assignment_type, course: @course)
      @assignment = create(:assignment)
      @course.assignments << @assignment
      @student = create(:user, first_name: "First Name", last_name: 'Last Name')
      @student.courses << @course
      @second_student = create(:user)
      @second_student.courses << @course
      @third_student = create(:user)
      @third_student.courses << @course
      @group = create(:group)
      @assignment.groups << @group
      @group.students << [@student, @second_student, @third_student]

      @grade = create(:grade)
      @assignment.grades << @grade

      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

    describe "GET show" do
      it "shows the grade" do
        get :show, { :id => @grade.id, :assignment_id => @assignment.id, :student_id => @student.id }
        GradesController.stub(:current_student).and_return(@student)
        assigns(:assignment).should eq(@assignment)
        assigns(:title).should eq("#{@student.name}'s Grade for #{@assignment.name}")
        response.should render_template(:show)
      end
    end

    describe "GET edit" do
      it "shows the grade edit form" do
        get :edit, { :id => @grade.id, :assignment_id => @assignment.id, :student_id => @student.id }
        GradesController.stub(:current_student).and_return(@student)
        assigns(:assignment).should eq(@assignment)
        assigns(:title).should eq("Grading #{@student.name}'s #{@assignment.name}")
        response.should render_template(:edit)
      end
    end

    describe "POST update" do
      it "updates the grade" do
        pending
        params = { raw_score: 1000, assignment_id: @assignment.id }
        post :update, { :id => @grade.id, :assignment_id => @assignment.id, :student_id => @student.id }, :grade => params
        @grade.reload
        response.should redirect_to(assignment_path(@grade.assignment))
        @grade.score.should eq(1000)
      end
    end

    describe "GET mass_edit" do
      it "assigns params" do
        get :mass_edit, :id => @assignment.id
        assigns(:title).should eq("Quick Grade #{@assignment.name}")
        response.should render_template(:mass_edit)
      end
    end

    describe "PUT mass_update" do
      let(:grades_attributes) do
        { "0" => { graded_by_id: @professor.id, instructor_modified: true,
                   student_id: @student.id, raw_score: 1000, status: "Graded", id: @grade.id }}
      end

      it "updates the grades for the specific assignment" do
        put :mass_update, id: @assignment.id, assignment: { grades_attributes: grades_attributes }
        expect(@grade.reload.raw_score).to eq 1000
      end

      it "sends a notification to the student to inform them of a new grade" do
        run_background_jobs_immediately do
          expect { put :mass_update, id: @assignment.id, assignment: { grades_attributes: grades_attributes } }.to \
            change { ActionMailer::Base.deliveries.count }.by 1
        end
      end

      it "only sends notifications to the students if the grade changed" do
        @grade.update_attributes({ raw_score: 1000 })
        run_background_jobs_immediately do
          expect { put :mass_update, id: @assignment.id, assignment: { grades_attributes: grades_attributes } }.to_not \
            change { ActionMailer::Base.deliveries.count }
        end
      end
    end

    describe "GET group_edit" do
      it "assigns params" do
        get :group_edit, { :id => @assignment.id, :group_id => @group.id}
        assigns(:title).should eq("Grading #{@group.name}'s #{@assignment.name}")
        response.should render_template(:group_edit)
      end
    end

    describe "GET edit_status" do
      it "displays the edit status page" do
        get :edit_status, {:grade_ids => [@grade.id], :id => @assignment.id}
        assigns(:title).should eq("#{@assignment.name} Grade Statuses")
        response.should render_template(:edit_status)
      end
    end

    describe "GET import" do
      it "displays the import page" do
        get :import, { :id => @assignment.id}
        assigns(:title).should eq("Import Grades for #{@assignment.name}")
        response.should render_template(:import)
      end
    end
  end

  context "as student" do
    before do
      @course = create(:course)
      @student = create(:user)
      @student.courses << @course
      login_user(@student)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
      @assignment_type = create(:assignment_type, course: @course)
      @assignment = create(:assignment)
      @course.assignments << @assignment
      @grade = create(:grade)
      @assignment.grades << @grade
      @group = create(:group)
      @assignment.groups << @group
    end

    describe "GET show" do
      it "shows the grade display" do
        get :show, {:grade_id => @grade.id, :assignment_id => @assignment.id}
        expect(response).to redirect_to(assignment_path(@assignment))
      end
    end

    describe "POST predict_score" do
      it "posts to the predict score path" do
        pending
        get :predict_score, {:grade_id => @grade.id, :id => @assignment.id, :student_id => @student.id }
        (expect(response.status).to eq(200))
      end
    end

    describe "POST self_log" do
      it "creates a maximum score by the student" do
        post :self_log, id: @assignment.id, present: "true"
        grade = @assignment.grades.last
        expect(grade.reload.raw_score).to eq @assignment.point_total
      end
    end

    describe "protected routes" do
      describe "GET edit" do
        it "redirects to root path" do
          get :edit, {:grade_id => @grade.id, :assignment_id => @assignment.id}
          response.should redirect_to(:root)
        end
      end

      describe "GET update" do
        it "redirects to root path" do
          get :update, {:grade_id => @grade.id, :assignment_id => @assignment.id}
          response.should redirect_to(:root)
        end
      end

      describe "GET submit_rubric" do
        it "redirects to root path" do
          get :submit_rubric, {:grade_id => @grade.id, :assignment_id => @assignment.id}
          response.should redirect_to(:root)
        end
      end

      describe "GET remove" do
        it "redirects to root path" do
          get :remove, { :id => @assignment.id, :grade_id => @grade.id}
          response.should redirect_to(:root)
        end
      end

      describe "DELETE destroy" do
        it "redirects to root path" do
          delete :destroy, {:grade_id => @grade.id, :assignment_id => @assignment.id}
          response.should redirect_to(:root)
        end
      end

      describe "GET mass_edit" do
        it "redirects to root path" do
          get :mass_edit, { :id => @assignment.id }
          response.should redirect_to(:root)
        end
      end

      describe "GET mass_update" do
        it "redirects to root path" do
          post :mass_update, { :id => @assignment.id}
          response.should redirect_to(:root)
        end
      end

      describe "GET group_edit" do
        it "redirects to root path" do
          get :group_edit, { :id => @assignment.id, :group_id => @group.id}
          response.should redirect_to(:root)
        end
      end

      describe "GET group_update" do
        it "redirects to root path" do
          post :group_update, { :id => @assignment.id, :group_id => @group.id}
          response.should redirect_to(:root)
        end
      end

      describe "GET edit_status" do
        it "redirects to root path" do
          get :edit_status, {:grade_ids => [@grade.id], :id => @assignment.id}
          response.should redirect_to(:root)
        end
      end

      describe "POST update_status" do
        it "redirects to root path" do
          post :update_status, {:grade_ids => @grade.id, :id => @assignment.id}
          response.should redirect_to(:root)
        end
      end

      describe "GET import" do
        it "redirects to root path" do
          get :import, { :id => @assignment.id}
          response.should redirect_to(:root)
        end
      end

      describe "GET username_import" do
        it "redirects to root path" do
          get :username_import, { :id => @assignment.id}
          response.should redirect_to(:root)
        end
      end

      describe "GET email_import" do
        it "redirects to root path" do
          post :email_import, { :id => @assignment.id}
          response.should redirect_to(:root)
        end
      end
    end
  end
end
