require "rails_spec_helper"

describe API::Grades::EarnedBadgesController do
  let(:world) { World.create.with(:course, :grade, :badge) }
  let(:professor) { create(:professor_course_membership, course: world.course).user }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "DELETE delete_all" do
      it "deletes all earned badges for a grade" do
        earned_badge_1 = create(:earned_badge, grade: world.grade)
        earned_badge_2 = create(:earned_badge, grade: world.grade)

        expect { delete :delete_all, grade_id: world.grade.id }.to \
          change { EarnedBadge.count }.by(-2)
        expect(JSON.parse(response.body)).to \
          eq({"message" => "Earned badges successfully deleted", "success" => true})
      end

      it "renders error if no badges found to delete" do
        delete :delete_all, grade_id: world.grade.id

        expect(JSON.parse(response.body)).to \
          eq({"message" => "Earned badges failed to delete", "success" => false})
      end
    end
  end
end
