#spec/controllers/challenges_controller_spec.rb
require 'spec_helper'

describe ChallengesController do

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

      login_user(@professor)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

		describe "GET index" do 
      it "returns challenges for the current course" do
        get :index
        assigns(:title).should eq("team Challenges")
        assigns(:challenges).should eq(@challenges)
        response.should render_template(:index)
      end
    end

		describe "GET show" do 
      it "returns the challenge show page" do
        get :show, :id => @challenge.id
        assigns(:title).should eq(@challenge.name)
        assigns(:challenge).should eq(@challenge)
        response.should render_template(:show)
      end
    end

		describe "GET new" do 
      it "assigns title and challenge" do
        get :new
        assigns(:title).should eq("Create a New team Challenge")
        assigns(:challenge).should be_a_new(Challenge)
        response.should render_template(:new)
      end
    end

    describe "GET edit" do
      it "edit title" do
        get :edit, :id => @challenge.id
        assigns(:title).should eq("Editing #{@challenge.name}")
        assigns(:challenge).should eq(@challenge)
        response.should render_template(:edit)
      end
    end

		describe "POST create" do 
      it "creates the challenge with valid attributes"  do
        params = attributes_for(:challenge)
        params[:challenge_id] = @challenge
        expect{ post :create, :challenge => params }.to change(Challenge,:count).by(1)
      end

      it "manages file uploads" do
        Challenge.delete_all
        params = attributes_for(:challenge)
        params[:challenge_id] = @challenge
        params.merge! :challenge_files_attributes => {"0" => {"file" => [fixture_file('test_file.txt', 'txt')]}}
        post :create, :challenge => params
        challenge = Challenge.where(name: params[:name]).last
        expect challenge.challenge_files.count.should eq(1)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, challenge: attributes_for(:challenge, name: nil) }.to_not change(Challenge,:count)
      end
    end

		describe "POST update" do
      it "updates the challenge" do
        params = { name: "new name" }
        post :update, id: @challenge.id, :challenge => params
        @challenge.reload
        response.should redirect_to(challenges_path)
        @challenge.name.should eq("new name")
      end

      it "manages file uploads" do
        params = {:challenge_files_attributes => {"0" => {"file" => [fixture_file('test_file.txt', 'txt')]}}}
        post :update, id: @challenge.id, :challenge => params
        expect @challenge.challenge_files.count.should eq(1)
      end
    end

		describe "GET destroy" do
      it "destroys the challenge" do
        expect{ get :destroy, :id => @challenge }.to change(Challenge,:count).by(-1)
      end
    end

	end

	context "as student" do 

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
          (get route, {:id => "1"}).should redirect_to(:root)
        end
      end
    end

	end
end