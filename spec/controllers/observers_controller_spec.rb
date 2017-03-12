describe ObserversController do
  let(:course) { build_stubbed(:course) }
  before(:each) { allow(controller).to receive(:current_course).and_return course }

  context "as a professor" do
    let(:professor) { build_stubbed(:user, courses: [course], role: :professor) }
    before(:each) { login_user(professor) }

    describe "GET index" do
      let!(:observer) { create(:user, courses: [course], role: :observer) }

      it "returns all observers for the current course" do
        get :index
        expect(assigns(:observers)).to eq([observer])
        expect(response).to render_template(:index)
      end
    end
  end

  context "as a student" do
    let(:student) { build_stubbed(:user, courses: [course], role: :student) }
    before(:each) { login_user(student) }

    describe "GET index" do
      it "redirects to root" do
        expect(get :index).to redirect_to(:root)
      end
    end
  end
end
