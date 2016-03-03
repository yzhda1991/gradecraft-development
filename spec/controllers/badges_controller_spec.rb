require "rails_spec_helper"

describe BadgesController do
  before(:all) do
    @course = create(:course)
    @student = create(:user)
    @student.courses << @course
    @badge = create(:badge, course: @course)
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

    before(:each) { login_user(@professor) }

    describe "GET index" do
      it "returns badges for the current course" do
        get :index
        expect(assigns(:title)).to eq("badges")
        expect(assigns(:badges)).to eq([@badge])
        expect(response).to render_template(:index)
      end
    end

    describe "GET show" do
      it "displays the badge page" do
        get :show, id: @badge.id
        expect(assigns(:title)).to eq(@badge.name)
        expect(assigns(:badge)).to eq(@badge)
        expect(response).to render_template(:show)
      end

      describe "with team id in params" do
        it "assigns team and students for team" do
          # we verify only students on team assigned as @students
          other_student = create(:user)
          other_student.courses << @course

          team = create(:team, course: @course)
          team.students << @student

          get :show, { id: @badge.id, team_id: team.id }
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

          get :show, id: @badge.id
          expect(assigns(:students)).to include(@student)
          expect(assigns(:students)).to include(other_student)
        end
      end
    end

    describe "GET new" do
      it "renders the new badge form" do
        get :new
        expect(assigns(:title)).to eq("Create a New badge")
        expect(assigns(:badge)).to be_a_new(Badge)
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "renders the edit badge form" do
        get :edit, id: @badge.id
        expect(assigns(:title)).to eq("Editing #{@badge.name}")
        expect(assigns(:badge)).to eq(@badge)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST create" do
      it "creates the badge with valid attributes"  do
        params = attributes_for(:badge)
        expect{ post :create, badge: params }.to change(Badge,:count).by(1)
      end

      it "manages file uploads" do
        Badge.delete_all
        params = attributes_for(:badge)
        params.merge! badge_files_attributes: {"0" => {"file" => [fixture_file("test_file.txt", "txt")]}}
        post :create, badge: params
        badge = Badge.where(name: params[:name]).last
        expect expect(badge.badge_files.count).to eq(1)
      end

      it "redirects to new form with invalid attributes" do
        expect{ post :create, badge: attributes_for(:badge, name: nil) }.to_not change(Badge,:count)
      end
    end

    describe "POST update" do
      before do
        @badge_2 = create(:badge, course: @course)
      end

      it "updates the badge" do
        params = { name: "new name" }
        post :update, id: @badge_2.id, badge: params
        expect(response).to redirect_to(badges_path)
        expect(@badge_2.reload.name).to eq("new name")
      end

      it "manages file uploads" do
        params = {badge_files_attributes: {"0" => {"file" => [fixture_file("test_file.txt", "txt")]}}}
        post :update, id: @badge_2.id, badge: params
        expect expect(@badge_2.badge_files.count).to eq(1)
      end

      it "redirects to edit form with invalid attributes" do
        params = { name: nil }
        post :update, id: @badge.id, badge: params
        expect(response).to render_template(:edit)
      end
    end

    describe "GET sort" do
      it "sorts the badges by params" do
        second_badge = create(:badge)
        @course.badges << second_badge
        params = [second_badge.id, @badge.id]
        post :sort, badge: params

        expect(@badge.reload.position).to eq(2)
        expect(second_badge.reload.position).to eq(1)
      end
    end

    describe "GET destroy" do
      it "destroys the badge" do
        another_badge = create :badge, course: @course
        expect{ get :destroy, id: another_badge }.to change(Badge,:count).by -1
      end
    end

    describe "GET predictor_data" do
      before do
        allow(controller).to receive(:current_course).and_return(@course)
        allow(controller).to receive(:current_user).and_return(@professor)
      end

      it "adds the prediction data to the badge model with prediction no less than earned" do
        prediction = create(:predicted_earned_badge, badge: @badge, student: @student, times_earned: 4)
        get :predictor_data, format: :json, id: @student.id
        expect(assigns(:badges)[0].prediction).to eq({ id: prediction.id, times_earned: 0 })
      end

      context "with a student id" do
        it "assigns the badges with no call to update" do
          get :predictor_data, format: :json, id: @student.id
          expect(assigns(:student)).to eq(@student)
          predictor_badge_attributes do |attr|
            expect(assigns(:badges)[0][attr]).to eq(@badge[attr])
          end
          expect(assigns(:update_badges)).to be_falsey
          expect(response).to render_template(:predictor_data)
        end
      end

      context "with no student" do
        it "assigns student as null student and no call to update" do
          get :predictor_data, format: :json
          expect(assigns(:student).class).to eq(NullStudent)
          expect(assigns(:update_badges)).to be_falsey
        end
      end
    end
  end

  context "as student" do
    before(:each) { login_user(@student) }

    describe "GET student_predictor_data" do
      describe "POST predict_times_earned" do
        it "updates the predicted times earned for a badge" do
          create(:predicted_earned_badge, badge: @badge, student: @student)
          predicted_times_earned = 4
          post :predict_times_earned, badge_id: @badge.id, times_earned: predicted_times_earned, format: :json
          expect(PredictedEarnedBadge.where(student: @student, badge: @badge).first.times_earned).to eq(4)
          expect(JSON.parse(response.body)).to eq({"id" => @badge.id, "times_earned" => predicted_times_earned})
        end

        it "doesn't update with invalid attributes" do
          skip "implement"
        end
      end

      describe "GET predictor_data" do
        it "assigns the student and badges with the call to update" do
          get :predictor_data, format: :json, id: @student.id
          expect(assigns(:student)).to eq(@student)
          @badge.reload
          predictor_badge_attributes.each do |attr|
            expect(assigns(:badges)[0][attr]).to eq(@badge[attr])
          end
          expect(assigns(:update_badges)).to be_truthy
          expect(response).to render_template(:predictor_data)
        end

        it "adds the prediction data to the badge model" do
          prediction = create(:predicted_earned_badge, badge: @badge, student: @student)
          get :predictor_data, format: :json, id: @student.id
          expect(assigns(:badges)[0].prediction).to eq({ id: prediction.id, times_earned: prediction.times_earned })
        end
      end
    end

    describe "protected routes" do
      [
        :index,
        :new,
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
        :show,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, {id: "1"}).to redirect_to(:root)
        end
      end
    end
  end

  # helper methods:
  def predictor_badge_attributes
    [
      :id,
      :name,
      :description,
      :point_total,
      :visible,
      :visible_when_locked,
      :can_earn_multiple_times,
      :position,
      :icon
    ]
  end
end
