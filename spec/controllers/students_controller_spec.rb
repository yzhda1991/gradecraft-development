describe StudentsController do
  let(:course) { build(:course) }
  let(:observer) { create(:user, courses: [course], role: :observer) }
  let(:professor) { create(:user, courses: [course], role: :professor) }
  let(:student) { create(:user, courses: [course], role: :student) }

  context "as a professor" do
    before(:each) { login_user(professor) }

    describe "GET index" do
      it "returns the students for the current course" do
        get :index
        expect(response).to render_template(:index)
      end
    end

    describe "GET show" do
      it "shows the student page" do
        get :show, params: { id: student.id }
        expect(response).to render_template(:show)
      end
    end

    describe "GET recalculate" do
      it "triggers the recalculation of a student's grade" do
        get :recalculate, params: { id: student.id }
        expect(response).to redirect_to(student_path(student))
      end
    end
  end

  context "as a student" do
    before { login_user(student) }

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
        :show,
        :recalculate
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, params: { id: "10" }).to redirect_to(:root)
        end
      end
    end
  end
end
