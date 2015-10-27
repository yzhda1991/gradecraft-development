require 'rails_spec_helper'

describe ChallengeGradesController do
  before(:all) do
    @course = create(:course)
    @student = create(:user)
    @student.courses << @course
    @team = create(:team, course: @course)
    @team.students << @student
    @challenge = create(:challenge, course: @course)
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

    before(:each) do
      @challenge_grade = create(:challenge_grade, team: @team, challenge: @challenge)
      login_user(@professor)
    end

    describe "GET index" do
      it "redirects the user to the challenge" do
        get :index, :challenge_id => @challenge
        expect(assigns(:challenge)).to eq(@challenge)
        expect(response).to redirect_to(@challenge)
      end
    end

    describe "GET show" do
      it "shows the challenge grade" do
        get :show, {:id => @challenge_grade, :challenge_id => @challenge}
        expect(assigns(:challenge)).to eq(@challenge)
        expect(assigns(:challenge_grade)).to eq(@challenge_grade)
        expect(assigns(:team)).to eq(@team)
        expect(response).to render_template(:show)
      end
    end

    describe "GET new" do
      it "shows the new challenge grade form" do
        get :new, {:challenge_id => @challenge, :team_id => @team}
        expect(assigns(:challenge)).to eq(@challenge)
        expect(assigns(:team)).to eq(@team)
        expect(assigns(:teams)).to eq([@team])
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "shows the edit challenge grade form" do
        get :edit, {:id => @challenge_grade, :challenge_id => @challenge}
        expect(assigns(:challenge)).to eq(@challenge)
        expect(assigns(:challenge_grade)).to eq(@challenge_grade)
        expect(assigns(:teams)).to eq([@team])
        expect(response).to render_template(:edit)
      end
    end

    describe "POST create" do
      it "creates the challenge grade with valid attributes"  do
        params = attributes_for(:challenge_grade)
        params[:challenge_id] = @challenge.id
        params[:team_id] = @team.id
        expect{ post :create, :challenge_id => @challenge.id, :challenge_grade => params }.to change(ChallengeGrade,:count).by(1)
      end

      it "redirects to new form with invalid attributes" do
        expect{ post :create, :challenge_id => @challenge.id, challenge_grade: attributes_for(:challenge_grade, team_id: nil) }.to_not change(ChallengeGrade,:count)
      end
    end

    describe "POST update" do
      it "updates the challenge grade" do
        params = { score: 100000 }
        post :update, :challenge_id => @challenge.id, :id => @challenge_grade.id, :challenge_grade => params
        expect(response).to redirect_to(challenge_path(@challenge))
        expect(@challenge_grade.reload.score).to eq(100000)
      end
    end

    describe "GET mass_edit" do
      it "assigns params" do
        get :mass_edit, :challenge_id => @challenge.id
        expect(assigns(:title)).to eq("Quick Grade #{@challenge.name}")
        expect(response).to render_template(:mass_edit)
      end
    end

    describe "GET edit_status" do
      it "displays the edit_status page" do
        get :edit_status, {:challenge_id => @challenge.id, :challenge_grade_ids => [ @challenge_grade.id ]}
        expect(assigns(:title)).to eq("#{@challenge.name} Grade Statuses")
        expect(response).to render_template(:edit_status)
      end
    end

    describe "GET destroy" do
      it "destroys the challenge grade" do
        expect{ get :destroy, {:id => @challenge_grade, :challenge_id => @challenge.id } }.to change(ChallengeGrade,:count).by(-1)
      end
    end
  end

  context "as student" do
    before(:each) do
      @challenge_grade = create(:challenge_grade, team: @team, challenge: @challenge)
      login_user(@student)
    end

    describe "GET show" do
      it "shows the challenge grade" do
        get :show, {:id => @challenge_grade, :challenge_id => @challenge}
        expect(assigns(:challenge)).to eq(@challenge)
        expect(assigns(:challenge_grade)).to eq(@challenge_grade)
        expect(assigns(:team)).to eq(@team)
        expect(response).to render_template(:show)
      end
    end

    describe "protected routes" do
      [
        :index,
        :new,
        :create
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route, {:challenge_id => 2 }).to redirect_to(:root)
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
          expect(get route, {:challenge_id => 2, :id => "1"}).to redirect_to(:root)
        end
      end
    end
  end
end
