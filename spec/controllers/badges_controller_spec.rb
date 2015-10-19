#spec/controllers/badges_spec.rb
require 'spec_helper'

describe BadgesController do
	context "as professor" do
    before do
      @course = create(:course_accepting_groups)
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      @badge = create(:badge, course: @course)
      @student = create(:user)
      @student.courses << @course

      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

		describe "GET index" do
      it "returns badges for the current course" do
        get :index
        expect(assigns(:title)).to eq("badges")
        expect(assigns(:badges)).to eq([@badge])
        expect(response).to render_template(:index)
      end
    end

		describe "GET show" do
      it "returns badges for the current course" do
        get :show, :id => @badge.id
        expect(assigns(:title)).to eq(@badge.name)
        expect(assigns(:badge)).to eq(@badge)
        expect(response).to render_template(:show)
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
        get :edit, :id => @badge.id
        expect(assigns(:title)).to eq("Editing #{@badge.name}")
        expect(assigns(:badge)).to eq(@badge)
        expect(response).to render_template(:edit)
      end
    end

		describe "POST create" do
      it "creates the badge with valid attributes"  do
        params = attributes_for(:badge)
        expect{ post :create, :badge => params }.to change(Badge,:count).by(1)
      end

      it "manages file uploads" do
        Badge.delete_all
        params = attributes_for(:badge)
        params.merge! :badge_files_attributes => {"0" => {"file" => [fixture_file('test_file.txt', 'txt')]}}
        post :create, :badge => params
        badge = Badge.where(name: params[:name]).last
        expect expect(badge.badge_files.count).to eq(1)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, badge: attributes_for(:badge, name: nil) }.to_not change(Badge,:count)
      end
    end

		describe "POST update" do
      it "updates the badge" do
        params = { name: "new name" }
        post :update, id: @badge.id, :badge => params
        @badge.reload
        expect(response).to redirect_to(badges_path)
        expect(@badge.name).to eq("new name")
      end

      it "manages file uploads" do
        params = {:badge_files_attributes => {"0" => {"file" => [fixture_file('test_file.txt', 'txt')]}}}
        post :update, id: @badge.id, :badge => params
        expect expect(@badge.badge_files.count).to eq(1)
      end
    end

		describe "GET sort" do
      it "sorts the badges by params" do
        @second_badge = create(:badge)
        @course.badges << @second_badge
        params = [@second_badge.id, @badge.id]
        post :sort, :badge => params

        @badge.reload
        @second_badge.reload
        expect(@badge.position).to eq(2)
        expect(@second_badge.position).to eq(1)
      end
    end

		describe "GET destroy" do
      it "destroys the badge" do
        expect{ get :destroy, :id => @badge }.to change(Badge,:count).by(-1)
      end
    end

    describe "GET student_predictor_data" do

      before do
        allow(controller).to receive(:current_course).and_return(@course)
        allow(controller).to receive(:current_user).and_return(@professor)
      end

      describe "GET student_predictor_data" do

        context "with a student id" do
          it "assigns the assignments with no call to update" do
            get :student_predictor_data, format: :json, :id => @student.id
            expect(assigns(:student)).to eq(@student)
            expect(assigns(:badges)[0].attributes.length).to eq(predictor_badge_attributes.length)
            predictor_badge_attributes.length do |attr|
              expect(assigns(:badges)[0][attr]).to eq(@badge[attr])
            end
            expect(assigns(:update_badges)).to be_falsy
            expect(response).to render_template(:student_predictor_data)
          end
        end

        context "with no student" do
          it "assigns student as null student and no call to update" do
            get :student_predictor_data, format: :json
            expect(assigns(:student).class).to eq(NullStudent)
            expect(assigns(:update_assignments)).to be_falsy
          end
        end

        it "adds the prediction data to the badge model with prediction equal to earned" do
          prediction = create(:predicted_earned_badge, badge: @badge, student: @student, times_earned: 4)
          get :student_predictor_data, format: :json, :id => @student.id
          expect(assigns(:badges)[0].student_predicted_earned_badge).to eq({ id: prediction.id, times_earned: 0 })
        end
      end
    end
	end

	context "as student" do

    describe "GET student_predictor_data" do

      before do
        @course = create(:course)
        @student = create(:user)
        @student.courses << @course
        @badge = create(:badge, course: @course)
        login_user(@student)
        allow(controller).to receive(:current_course).and_return(@course)
        allow(controller).to receive(:current_user).and_return(@student)
      end

      it "assigns the student and badges with the call to update" do
        get :student_predictor_data, format: :json, :id => @student.id
        expect(assigns(:student)).to eq(@student)
        expect(assigns(:badges)[0].attributes.length).to eq(predictor_badge_attributes.length)
        predictor_badge_attributes.length do |attr|
          expect(assigns(:badges)[0][attr]).to eq(@badge[attr])
        end
        expect(assigns(:update_badges)).to be_truthy
        expect(response).to render_template(:student_predictor_data)
      end

      it "adds the prediction data to the badge model" do
        prediction = create(:predicted_earned_badge, badge: @badge, student: @student)
        get :student_predictor_data, format: :json, :id => @student.id
        expect(assigns(:badges)[0].student_predicted_earned_badge).to eq({ id: prediction.id, times_earned: prediction.times_earned })
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
          expect(get route, {:id => "1"}).to redirect_to(:root)
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
      :updated_at,
      :icon
    ]
  end
end
