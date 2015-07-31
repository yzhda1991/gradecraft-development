#spec/controllers/challenge_grades_controller_spec.rb
require 'spec_helper'

describe ChallengeGradesController do

	context "as professor" do 

    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @challenge = create(:challenge, course: @course)
      @course.challenges << @challenge
      @challenges = @course.challenges
      @student = create(:user)
      @student.courses << @course
      @team = create(:team, course: @course)
      @team.students << @student
      @teams = @course.teams
      @challenge_grade = create(:challenge_grade, team: @team, challenge: @challenge)

      login_user(@professor)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

		describe "GET index" do 
      it "redirects the user to the challenge" do
        get :index, :challenge_id => @challenge
        assigns(:challenge).should eq(@challenge)
        response.should redirect_to(@challenge)
      end
    end

		describe "GET show" do 
      it "shows the challenge grade" do
        get :show, {:id => @challenge_grade, :challenge_id => @challenge}
        assigns(:challenge).should eq(@challenge)
        assigns(:challenge_grade).should eq(@challenge_grade)
        assigns(:team).should eq(@team)
        response.should render_template(:show)
      end
    end

		describe "GET new" do  
      it "shows the new challenge grade form" do
        get :new, {:challenge_id => @challenge, :team_id => @team}
        assigns(:challenge).should eq(@challenge)
        assigns(:team).should eq(@team)
        assigns(:teams).should eq([@team])
        response.should render_template(:new)
      end
    end

		describe "GET edit" do  
      it "shows the edit challenge grade form" do
        get :edit, {:id => @challenge_grade, :challenge_id => @challenge}
        assigns(:challenge).should eq(@challenge)
        assigns(:challenge_grade).should eq(@challenge_grade)
        assigns(:teams).should eq([@team])
        response.should render_template(:edit)
      end
    end

		describe "GET mass_edit" do  
      it "assigns params" do
        get :mass_edit, :challenge_id => @challenge.id
        assigns(:title).should eq("Quick Grade #{@challenge.name}")
        response.should render_template(:mass_edit)
      end
    end

		describe "POST create" do  
      pending
    end

		describe "POST update" do  
      pending
    end

		describe "POST mass_update" do  
      pending
    end

		describe "GET edit_status" do 
      it "displays the edit_status page" do 
        get :edit_status, {:challenge_id => @challenge.id, :challenge_grade_ids => [ @challenge_grade.id ]}
        assigns(:title).should eq("#{@challenge.name} Grade Statuses")
        response.should render_template(:edit_status)
      end
    end

		describe "POST update_status" do  
      pending
    end

		describe "GET destroy" do
      it "destroys the challenge grade" do
        expect{ get :destroy, {:id => @challenge_grade, :challenge_id => @challenge.id } }.to change(ChallengeGrade,:count).by(-1)
      end
    end

	end

	context "as student" do 

    before do
      @course = create(:course)
      @challenge = create(:challenge, course: @course)
      @course.challenges << @challenge
      @challenges = @course.challenges
      @student = create(:user)
      @student.courses << @course
      @team = create(:team, course: @course)
      @team.students << @student
      @teams = @course.teams
      @challenge_grade = create(:challenge_grade, team: @team, challenge: @challenge)

      login_user(@student)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

		describe "GET show" do 
      it "shows the challenge grade" do
        get :show, {:id => @challenge_grade, :challenge_id => @challenge}
        assigns(:challenge).should eq(@challenge)
        assigns(:challenge_grade).should eq(@challenge_grade)
        assigns(:team).should eq(@team)
        response.should render_template(:show)
      end
    end

		describe "protected routes" do
			
      [
        :index,
        :new,
        :create

      ].each do |route|
          it "#{route} redirects to root" do
            (get route, {:challenge_id => 2 }).should redirect_to(:root)
          end
        end
    end


    describe "protected routes requiring id in params" do

      [
        :edit,
        :mass_edit,
        :mass_update,
        :edit_status,
        :update_status,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          (get route, {:challenge_id => 2, :id => "1"}).should redirect_to(:root)
        end
      end
    end

	end
end