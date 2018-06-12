describe ObserversController do
  let(:course) { create(:course) }
  let(:observer) { create(:user, courses: [course], role: :observer) }
  let(:professor) { create(:user, courses: [course], role: :professor) }
  let(:student) { create(:user, courses: [course], role: :student) }

  context "as a professor" do
    before(:each) { login_user(professor) }

    describe "GET index" do
      it "returns all observers for the current course" do
        observer
        get :index
        expect(assigns(:observers)).to eq([observer])
        expect(response).to render_template(:index)
      end
    end
  end

  context "as a student" do
    before(:each) { login_user(student) }

    describe "GET index" do
      it "redirects to root" do
        expect(get :index).to redirect_to(:root)
      end
    end
  end
end
