require 'spec_helper'

describe UsersController do

	context "as a professor" do

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
      @users = @course.users

      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

		describe "GET index" do
      it "returns the users for the current course" do
        get :index
        assigns(:title).should eq("All Users")
        assigns(:users).should eq(@users)
        response.should render_template(:index)
      end
    end

    describe "GET new" do
      it "assigns the name" do
        get :new
        assigns(:title).should eq("Create a New User")
        assigns(:user).should be_a_new(User)
        response.should render_template(:new)
      end
    end

    describe "GET edit" do
      it "renders the edit user form" do
        get :edit, :id => @student.id
        assigns(:title).should eq("Editing #{@student.name}")
        assigns(:user).should eq(@student)
        response.should render_template(:edit)
      end
    end

		describe "GET create" do
      pending
    end

		describe "GET update" do
      pending
    end

    describe "GET destroy" do
      it "destroys the user" do
        expect{ get :destroy, {:id => @student } }.to change(User,:count).by(-1)
      end
    end


		describe "GET edit_profile" do
      it "renders the edit profile user form" do
        get :edit_profile
        assigns(:title).should eq("Edit My Profile")
        assigns(:user).should eq(@professor)
        response.should render_template(:edit_profile)
      end
    end

		describe "GET update_profile" do
      it "successfully updates the users profile" do
        params = { display_name: "gandalf" }
        post :update_profile, id: @professor.id, :user => params
        @professor.reload
        response.should redirect_to(dashboard_path)
        @professor.display_name.should eq("gandalf")
      end
    end

		describe "GET import" do
      it "renders the import page" do
        get :import
        response.should render_template(:import)
      end
    end

		describe "GET upload" do
      pending
    end

	end

	context "as a student" do

    before do
      @course = create(:course)
      @student = create(:user)
      @student.courses << @course

      login_user(@student)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

		describe "GET edit_profile" do
      it "renders the edit profile user form" do
        get :edit_profile
        assigns(:title).should eq("Edit My Profile")
        assigns(:user).should eq(@student)
        response.should render_template(:edit_profile)
      end
    end

		describe "GET update_profile" do
      it "successfully updates the users profile" do
        params = { display_name: "frodo" }
        post :update_profile, id: @student.id, :user => params
        @student.reload
        response.should redirect_to(dashboard_path)
        @student.display_name.should eq("frodo")
      end
    end


		describe "protected routes" do
      [
        :index,
        :new,
        :create,
        :import,
        :upload
      ].each do |route|
          it "#{route} redirects to root" do
            (get route).should redirect_to(:root)
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
          (get route, {:id => "1"}).should redirect_to(:root)
        end
      end
    end

	end
end
