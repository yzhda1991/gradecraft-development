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

			@grade = create(:grade)
			@assignment.grades << @grade

      login_user(@professor)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
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

		describe "POST submit_rubric" do  
      pending
    end

		describe "GET remove" do  
      pending
    end

		describe "GET destroy" do
      it "destroys the grade" do
      	pending
        expect{ get :destroy, {:id => @grade, :assignment_id => @assignment.id } }.to change(Grade,:count).by(-1)
      end
    end

		describe "GET self_log" do  
      pending
    end

		describe "POST predict_score" do  
      pending
    end

		describe "GET mass_edit" do  
      pending
    end

		describe "POST mass_update" do  
      pending
    end

		describe "GET group_edit" do  
      pending
    end

		describe "POST group_update" do  
      pending
    end

		describe "GET edit_status" do  
      pending
    end

		describe "POST update_status" do  
      pending
    end

		describe "GET import" do  
      pending
    end

		describe "GET username_import" do  
      pending
    end

		describe "GET email_import" do  
      pending
    end

	end

	context "as student" do 

		before do
      @course = create(:course)
      @student = create(:user)
      @student.courses << @course
      login_user(@student)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
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
      it "posts a self-logged score" do
      	pending
        get :edit, {:grade_id => @grade.id, :assignment_id => @assignment.id}
  			(expect(response.status).to eq(200))
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
	      	pending
	        get :remove, {:assignment_id => @assignment.id, :grade_id => @grade.id}
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
	      	pending
	        get mass_grade_assignment_path(:id => @assignment.id)
	        response.should redirect_to(:root)
	      end
	    end

	    describe "GET mass_update" do
	      it "redirects to root path" do
	      	pending
	        get :mass_update, {:grade_id => @grade.id, :assignment_id => @assignment.id}
	  			response.should redirect_to(:root)
	      end
	    end

	    describe "GET group_edit" do
	      it "redirects to root path" do
	      	pending
	        get :group_edit, { :assignment_id => @assignment.id, :group_id => @group.id}
	  			response.should redirect_to(:root)
	      end
	    end

	    describe "GET group_update" do
	      it "redirects to root path" do
	      	pending
	        get :group_update, {:grade_id => @grade.id, :assignment_id => @assignment.id}
	  			response.should redirect_to(:root)
	      end
	    end

	    describe "POST edit_status" do
	      it "redirects to root path" do
	      	pending
	        post :edit_status, {:assignment_id => @assignment.id}
	  			response.should redirect_to(:root)
	      end
	    end

	    describe "GET update_status" do
	      it "redirects to root path" do
	      	pending
	        get :update_status, {:grade_id => @grade.id, :assignment_id => @assignment.id}
	  			response.should redirect_to(:root)
	      end
	    end

	    describe "GET import" do
	      it "redirects to root path" do
	      	pending
	        get :import, { :assignment_id => @assignment.id}
	  			response.should redirect_to(:root)
	      end
	    end

	    describe "GET username_import" do
	      it "redirects to root path" do
	      	pending
	        post :username_import, {:grade_id => @grade.id, :assignment_id => @assignment.id}
	  			response.should redirect_to(:root)
	      end
	    end

	    describe "GET email_import" do
	      it "redirects to root path" do
	      	pending
	        post :email_import, {:grade_id => @grade.id, :assignment_id => @assignment.id}
	  			response.should redirect_to(:root)
	      end
	    end
    end
	end
end
