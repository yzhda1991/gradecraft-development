describe MultipliersController do
    let(:course) { create :course }

    before(:each) do
        login_user current_user
    end

    context "as an instructor" do
        let(:current_user) { create(:user, courses: [course], role: :professor) }

        describe "GET #export" do
            it "requires membership in the provided course" do
                get :export, params: { course_id: course.id }, format: :csv
                expect(response).to have_http_status 200
            end

            it "generates a csv" do
                expect_any_instance_of(MultipliersExporter).to receive(:export).once
                get :export, params: { course_id: course.id }, format: :csv
            end
        end
    end

    context "as a student" do
        describe "GET #export" do
            let(:current_user) { create(:course_membership, role: :student, course: course).user }

            it "returns a redirect response" do
                get :export, params: { course_id: course.id }, format: :csv
                expect(response).to have_http_status 302
            end
        end
    end
end
