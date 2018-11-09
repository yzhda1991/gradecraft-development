include SessionHelper

describe API::BadgesController do
  let(:course) { create(:course, status: true) }
  let(:student) { create(:user, courses: [course], role: :student) }
  let(:professor) { create(:user, courses: [course], role: :professor) }
  let(:badge) { create(:badge, course: course) }

  context "as professor" do
    before do
      login_user(professor)
      allow(controller).to receive(:current_course).and_return(course)
      allow(controller).to receive(:current_user).and_return(professor)
    end

    describe "GET index" do
      it "assigns badges, no student, and no call to update" do
        badge
        get :index, format: :json
        predictor_badge_attributes.each do |attr|
          expect(assigns(:badges)[0][attr]).to eq(badge[attr])
        end
        expect(assigns(:student)).to be_nil
        expect(assigns(:allow_updates)).to be_falsey
      end
    end

    describe "GET sort" do
      it "sorts the badges by params" do
        second_badge = create(:badge)
        course.badges << second_badge
        params = [second_badge.id, badge.id]
        post :sort, params: { badge: params }, format: :json

        expect(badge.reload.position).to eq(2)
        expect(second_badge.reload.position).to eq(1)
      end
    end

    describe "POST create" do
      it "creates the badge with valid attributes"  do
        badge_params = attributes_for(:badge).merge! name: "New Badge", auto_award_after_unlock: true
        expect{ post :create, params: { badge: badge_params }, format: :json }.to change(Badge, :count).by(1)
        badge = Badge.last
        expect(badge.name).to eq "New Badge"
        expect(badge.auto_award_after_unlock).to eq true
      end

      it "does not create new badge with invalid attributes" do
        expect{ post :create, params: { badge: { name: nil }}, format: :json }
          .to_not change(Badge,:count)
      end
    end

    describe "PUT update" do
      it "updates the badge" do
        badge
        put :update, params: { id: badge.id, badge: { name: "new name", auto_award_after_unlock: true }}, format: :json
        badge.reload
        expect(badge.name).to eq("new name")
        expect(badge.auto_award_after_unlock).to eq true
      end
    end
  end

  context "as student" do
    before(:each) { login_user(student) }

    describe "GET index" do
      before do
        allow(controller).to receive(:current_course).and_return(course)
      end

      context "when the course is active" do
        it "assigns the student and badges with the call to update" do
          get :index, format: :json
          expect(assigns(:student)).to eq(student)
          badge.reload
          predictor_badge_attributes.each do |attr|
            expect(assigns(:badges)[0][attr]).to eq(badge[attr])
          end
          expect(assigns(:allow_updates)).to be_truthy
          expect(response).to render_template(:index)
        end
      end

      context "when the course is inactive" do
        it "assigns the student and badges with the call to update" do
          course.status = false
          get :index, format: :json
          expect(assigns(:student)).to eq(student)
          badge.reload
          predictor_badge_attributes.each do |attr|
            expect(assigns(:badges)[0][attr]).to eq(badge[attr])
          end
          expect(assigns(:allow_updates)).to be_falsey
          expect(response).to render_template(:index)
        end
      end

      it "adds the student's predicted earned badges" do
        prediction = create(:predicted_earned_badge, badge: badge, student: student)
        get :index, params: { id: student.id }, format: :json
        expect(assigns(:predicted_earned_badges)[0]).to eq(prediction)
      end
    end

    it "redirects protected routes to root" do
      [
        -> { post :sort, params: { "badge" => [badge] }, format: :json}
      ].each do |protected_route|
        expect(protected_route.call).to redirect_to(:root)
      end
    end
  end

  context "as faculty previewing as student" do
    before do
      login_as_impersonating_agent(professor, student)
      @badge = badge
      allow(controller).to receive(:current_course).and_return(course)
    end

    describe "GET index" do
      it "assigns badges, no prediction and no call to update" do
        get :index, format: :json
        predictor_badge_attributes.each do |attr|
          expect(assigns(:badges)[0][attr]).to eq(@badge[attr])
        end
        expect(assigns(:predicted_earned_badges)).to be_nil
        expect(assigns(:update_badges)).to be_falsey
      end
    end
  end

  # helper methods:
  def predictor_badge_attributes
    [
      :id,
      :name,
      :description,
      :full_points,
      :visible,
      :visible_when_locked,
      :can_earn_multiple_times,
      :position,
      :icon
    ]
  end
end
