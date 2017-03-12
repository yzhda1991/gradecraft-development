describe API::BadgesController do
  let(:course) { build_stubbed(:course) }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:badge) { create(:badge, course: course) }
  let(:professor) { create(:course_membership, :professor, course: course).user }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "GET index" do
      before do
        allow(controller).to receive(:current_course).and_return(course)
        allow(controller).to receive(:current_user).and_return(professor)
        @badge = badge
      end

      it "assigns badges, no student, and no call to update" do
        get :index, format: :json
        predictor_badge_attributes.each do |attr|
          expect(assigns(:badges)[0][attr]).to eq(@badge[attr])
        end
        expect(assigns(:student)).to be_nil
        expect(assigns(:allow_updates)).to be_falsey
      end
    end
  end

  context "as student" do
    before(:each) { login_user(student) }

    describe "GET index" do
      before do 
        allow(controller).to receive(:current_course).and_return(course)
      end
      
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

      it "adds the student's predicted earned badges" do
        prediction = create(:predicted_earned_badge, badge: badge, student: student)
        get :index, params: { id: student.id }, format: :json
        expect(assigns(:predicted_earned_badges)[0]).to eq(prediction)
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
