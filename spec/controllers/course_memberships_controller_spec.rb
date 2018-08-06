describe CourseMembershipsController do
  let(:course) { create :course }
  let(:professor_membership) { create :course_membership, :professor, course: course }
  let!(:professor) { professor_membership.user }

  context "as professor" do
    before(:each) { login_user professor }

    describe "PUT #deactivate" do
      let(:active_membership) { create :course_membership, :student, course: course, active: true }

      it "updates the course_membership attribute active to be false" do
        put :deactivate, params: { id: active_membership.id }
        expect(active_membership.reload.active).to eq false
      end
    end

    describe "PUT #reactivate" do
      let(:deactive_membership) { create :course_membership, :student, course: course, active: false }

      it "updates the course_membership attribute active to be true" do
        put :reactivate, params: { id: deactive_membership.id }
        expect(deactive_membership.reload.active).to eq true
      end
    end

    describe "protected routes" do
      it "redirects to root" do
        [
          -> { get :index },
          -> { delete :delete_many }
        ].each do |protected_route|
          expect(protected_route.call).to redirect_to root_path
        end
      end
    end
  end

  context "as admin" do
    let(:admin) { create :user, courses: [course], role: :admin }
    let!(:student_membership) { create :course_membership, :student, course: course }

    before(:each) do
      login_user admin
      allow(controller).to receive(:current_course).and_return course
    end

    describe "GET #index" do
      it "assigns the course memberships for the current course" do
        get :index
        expect(assigns(:users)).to match_array [student_membership.user, professor]
      end
    end

    describe "DELETE #delete_many" do
      it "alerts the user that the deletion was successful" do
        delete :delete_many, params: { course_membership_ids: [student_membership.id] }
        expect(flash[:success]).to match "Successfully deleted 1 course membership(s)"
      end

      it "delete course_memberships" do
        expect{ delete :delete_many, params: { course_membership_ids: [professor_membership.id] } }.to \
          change(CourseMembership, :count).by -1
      end
    end
  end
end
