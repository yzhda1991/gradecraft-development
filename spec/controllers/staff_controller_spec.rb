describe StaffController do
  let(:course) { build(:course) }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }

  context "as a professor" do
    before { login_user(professor) }

    describe "GET index" do
      it "returns all staff for the current course" do
        get :index
        expect(assigns(:staff)).to eq([professor])
        expect(response).to render_template(:index)
      end
    end

    describe "GET show" do
      it "displays a single staff member's page" do
        get :show, params: { id: professor.id }
        expect(assigns(:staff_member)).to eq(professor)
        expect(response).to render_template(:show)
      end
    end
  end

  context "as a student" do
    before(:each) { login_user(student) }

    describe "protected routes" do
      [
        :index
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route).to redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :show
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, params: { id: "1" }).to redirect_to(:root)
        end
      end
    end
  end
end
