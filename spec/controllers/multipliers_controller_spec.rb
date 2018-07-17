describe MultipliersController do
  let(:course_1) { create :course }
  let(:course_2) { create :course_with_weighting }

  before(:each) do
    login_user current_user
  end

  context "as an instructor" do
    let(:current_user) { create(:user, courses: [course_1, course_2], role: :professor) }

    describe "GET #export" do
      it "requires membership in the provided course" do
        get :export, params: { course_id: course_1.id }, format: :csv
        expect(response).to have_http_status 302
      end

      it "get flash error message if the course doesn't enable weights" do
        get :export, params: { course_id: course_1.id }, format: :csv
        expect(flash[:error]).to match /This course doesn't have multipliers/
      end

      it "generates a csv if the course has weights enabled" do
        expect_any_instance_of(MultipliersExporter).to receive(:export).once
        get :export, params: { course_id: course_2.id }, format: :csv
      end
    end
  end

  context "as a student" do
    describe "GET #export" do
      let(:current_user) { create(:course_membership, role: :student, course: course_2).user }

      it "returns a redirect response" do
        get :export, params: { course_id: course_2.id }, format: :csv
        expect(response).to have_http_status 302
      end
    end
  end
end
