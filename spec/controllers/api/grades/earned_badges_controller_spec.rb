describe API::Grades::EarnedBadgesController do
  let(:course) { build :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:grade) { create(:grade, student: student) }
  let(:badge) { create(:badge, course: course) }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "POST create" do
      it "creates new earned badges from params" do
        badge_1 = create(:badge)
        badge_2 = create(:badge)
        badge_3 = create(:badge)
        params = { grade_id: grade.id,
                   earned_badges: [{ badge_id: badge_1.id, student_id: student },
                                   { badge_id: badge_2.id, student_id: student },
                                   { badge_id: badge_3.id, student_id: student }]}
        expect { post :create, params: params }.to change { EarnedBadge.count }.by(3)
      end
    end

    describe "DELETE delete_all" do
      it "deletes all earned badges for a grade" do
        earned_badge_1 = create(:earned_badge, grade: grade)
        earned_badge_2 = create(:earned_badge, grade: grade)

        expect { delete :delete_all, params: { grade_id: grade.id }}.to \
          change { EarnedBadge.count }.by(-2)
        expect(JSON.parse(response.body)).to \
          eq({"message" => "Earned badges successfully deleted", "success" => true})
      end

      it "renders error if no badges found to delete" do
        delete :delete_all, params: { grade_id: grade.id }

        expect(JSON.parse(response.body)).to \
          eq({"message" => "Earned badges failed to delete", "success" => false})
      end
    end
  end
end
