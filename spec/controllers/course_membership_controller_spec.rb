describe CourseMembershipsController do
  let(:course) { create :course }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:admin) { create(:course_membership, :admin, course: course).user }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "PUT #deactivate" do
      let(:active_membership) {   create :course_membership, :student, course: course, active: true  }

      it "updates the course_membership attribute active to be false" do
        put :deactivate, params: {id: active_membership.id}
        expect(active_membership.reload.active).to eq false
      end
    end

    describe "PUT #reactivate" do
      let(:deactive_membership) { create :course_membership, :student, course: course, active: false }

      it "updates the course_membership attribute active to be true" do
        put :reactivate, params: {id: deactive_membership.id}
        expect(deactive_membership.reload.active).to eq true
      end
    end
  end
end
