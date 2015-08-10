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

    describe "POST create" do
      let(:user) { User.unscoped.last }

      context "calling create" do
        before(:each) do
          post :create, user: { first_name: "Jimmy",
                                last_name: "Page",
                                username: "jimmy",
                                email: "jimmy@example.com" }
        end

        it "creates a new user" do
          expect(user.email).to eq "jimmy@example.com"
          expect(user.username).to eq "jimmy"
          expect(user.first_name).to eq "Jimmy"
          expect(user.last_name).to eq "Page"
        end

        it "generates a random password for a user" do
          expect(user.crypted_password).to_not be_blank
        end

        it "requires the new user to be activated" do
          expect(user.activation_token).to_not be_blank
          expect(user.activation_state).to eq "pending"
        end
      end

      it "sends an activation email for the user" do
        expect {
          post :create, user: { first_name: "Jimmy",
                                last_name: "Page",
                                username: "jimmy",
                                email: "jimmy@example.com" }
        }.to change { ActionMailer::Base.deliveries.count }.by 1
      end
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

    describe "POST upload" do
      let(:file) { fixture_file "users.csv", "text/csv" }

      before(:each) { post :upload, file: file }

      it "redirects to the users index page" do
        expect(response).to redirect_to users_path
      end

      it "creates the student accounts" do
        user = User.unscoped.last
        expect(user.email).to eq "jimmy@example.com"
        expect(user.crypted_password).to_not be_blank
      end
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

    describe "GET activate" do
      before(:each) { @student.update_attribute :activation_token, "blah" }

      it "exists" do
        get :activate, id: @student.activation_token
        expect(response).to be_success
      end

      it "redirects to the root url if the token is not correct" do
        get :activate, id: "blech"
        expect(response).to redirect_to root_path
      end
    end

    describe "POST activated" do
      before do
        @student.update_attribute :activation_token, "blah"
        @student.update_attribute :activation_state, "pending"
      end

      context "with matching passwords" do
        before do
          post :activated, id: @student.activation_token,
            token: @student.activation_token,
            user: { password: "blah", password_confirmation: "blah" }
        end

        it "activates the user" do
          expect(@student.reload.activation_state).to eq "active"
        end

        it "updates the user's password" do
          expect(User.authenticate(@student.email, "blah")).to eq @student
        end

        it "logs the user in" do
          expect(response).to redirect_to dashboard_path
        end
      end

      context "with a tampered activation token" do
        before do
          post :activated, id: @student.activation_token,
            token: "tampered",
            user: { password: "blah", password_confirmation: "blah" }
        end

        it "does not activate the user" do
          expect(@student.reload.activation_state).to eq "pending"
        end

        it "does not update the user's password" do
          expect(User.authenticate(@student.email, "blah")).to be_nil
        end

        it "redirects to the root url" do
          expect(response).to redirect_to root_path
        end
      end

      context "with a non-matching password" do
        before do
          post :activated, id: @student.activation_token,
            token: @student.activation_token,
            user: { password: "blah", password_confirmation: "blech" }
        end

        it "does not activate the user" do
          expect(@student.reload.activation_state).to eq "pending"
        end

        it "renders the activate template" do
          expect(response).to render_template :activate
        end
      end

      context "with a blank password" do
        before do
          post :activated, id: @student.activation_token,
            token: @student.activation_token,
            user: { password: "", password_confirmation: "" }
        end

        it "does not activate the user" do
          expect(@student.reload.activation_state).to eq "pending"
        end

        it "renders the activate template" do
          expect(response).to render_template :activate
        end
      end
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
