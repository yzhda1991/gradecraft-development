describe API::CourseCreationController do
  let!(:course) { build(:course)}
  let(:professor) { create(:course_membership, :professor, course: course).user }

  context "as a professor" do
    before do
      login_user(professor)
      allow(controller).to receive(:current_course).and_return(course)
    end

    describe "GET course creation" do
      it "returns the CourseCreation checklist for course" do
        course_creation = create :course_creation, course: course
        get :show, format: :json
        expect(assigns(:course_creation)).to eq(course_creation)
      end

      it "creates the CourseCreation model if none exists" do
        expect{get :show, format: :json}.to \
          change{ CourseCreation.count }.by(1)
      end
    end

    describe "PUT update course creation" do

      it "updates the field on the course creation" do
        course_creation = create :course_creation, course: course
        put :update, params: { course_creation: { settings_done: true }}, format: :json
        expect(course_creation.reload.settings_done).to be_truthy
      end
    end
  end
end
