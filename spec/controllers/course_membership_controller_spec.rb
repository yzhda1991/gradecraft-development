describe CourseMembershipsController, focus: true do
  let(:course) { create :course }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:admin) { create(:course_membership, :admin, course: course).user }

  before(:each) { Course.destroy_all }
  before(:each) { CourseMembership.destroy_all }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "PUT #deactivate" do
      let(:active_membership) { create :course_membership, :student, course: course, active: true }

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

  context "as admin" do
    before(:each) {login_user(admin)}
    let!(:student_2) { create(:course_membership, :student, course: course).user }

    describe "DELETE #delete_many" do
      it "check admin" do
        delete :delete_many, params: {course_membership_ids: [student.id]}
        expect(response).to have_http_status 302
      end

      it "get flash success message if successfully delete" do
        delete :delete_many, params: {course_membership_ids: [student.id]}
        expect(flash[:success]).to match /Delete memberships successfully/
      end

      it "delete course_memberships" do
        delete :delete_many, params: {course_membership_ids: [student.id, professor.id]}
        expect(course.users.includes(:course_memberships).where.not(course_memberships: { role: "admin" }).length).to eq 1
        expect(course.users.includes(:course_memberships).where.not(course_memberships: { role: "admin" }).pluck(:id)).to eq [student_2.id]
      end
    end
  end
end
