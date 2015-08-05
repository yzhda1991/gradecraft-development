#spec/controllers/teams_controller_spec.rb
require 'spec_helper'

describe TeamsController do

	context "as a professor" do

    before do
      @course = create(:course)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @student = create(:user)
      @student.courses << @course
      @team = create(:team)
      @course.teams << @team
      @teams = @course.teams

      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

    describe "GET index" do
      it "returns all teams for the current course" do
        get :index
        assigns(:title).should eq("teams")
        assigns(:teams).should eq(@teams)
        response.should render_template(:index)
      end
    end

    describe "GET show" do
      it "returns the team show page" do
        get :show, :id => @team.id
        assigns(:title).should eq(@team.name)
        assigns(:team).should eq(@team)
        response.should render_template(:show)
      end
    end

    describe "GET new" do
      it "assigns a name" do
        get :new
        assigns(:title).should eq("Create a New team")
        assigns(:team).should be_a_new(Team)
        response.should render_template(:new)
      end
    end

    describe "GET edit" do
      it "assigns name " do
        get :edit, :id => @team.id
        assigns(:title).should eq("Editing #{@team.name}")
        assigns(:team).should eq(@team)
        response.should render_template(:edit)
      end
    end

    describe "POST create" do
      it "creates the team with valid attributes"  do
        params = attributes_for(:team)
        params[:id] = @team
        expect{ post :create, :team => params }.to change(Team,:count).by(1)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, team: attributes_for(:team, name: nil) }.to_not change(Team,:count)
      end
    end

    describe "POST update" do
      it "updates the team" do
        params = { name: "new name" }
        post :update, id: @team.id, :team => params
        @team.reload
        response.should redirect_to(team_path(@team))
        @team.name.should eq("new name")
      end
    end

    describe "GET destroy" do
      it "destroys the team" do
        expect{ get :destroy, :id => @team }.to change(Team,:count).by(-1)
      end
    end
	end

	context "as a student" do

		describe "protected routes" do
      [
        :index,
        :new,
        :create
      ].each do |route|
          it "#{route} redirects to root" do
            (get route).should redirect_to(:root)
          end
        end
    end


    describe "protected routes requiring id in params" do
      [
        :edit,
        :show,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          (get route, {:id => "10"}).should redirect_to(:root)
        end
      end
    end

	end
end
