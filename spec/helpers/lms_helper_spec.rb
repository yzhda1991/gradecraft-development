describe LMSHelper do
  describe "#lms_user_match?" do
    let(:course) { create :course }

    context "the user does not exist" do
      it "returns false" do
        expect(helper.lms_user_match?("blah@blah.com", course)).to eq false
      end
    end

    context "the user exists" do
      let(:email) { "jimmy@example.com" }
      let!(:student) { create :user, email: email }

      it "returns false if the user does not belong to the course" do
        expect(helper.lms_user_match?(email, course)).to eq false
      end

      context "the user belongs to the course" do
        let!(:membership) { create :course_membership, :student, user: student, course: course }

        it "returns true if the user exists and belongs to the course" do
          expect(helper.lms_user_match?(email, course)).to eq true
        end
      end
    end
  end

  describe "#lms_user_role" do
    it "returns the observer role if no enrollments are given" do
      expect(helper.lms_user_role([])).to eq :observer
    end

    it "returns the observer role if the only enrollment type is unrecognized" do
      enrollments = [{ "type" => "HackerEnrollment" }]
      expect(helper.lms_user_role(enrollments)).to eq :observer
    end

    it "returns the translated Gradecraft role of highest precedence" do
      enrollments = [
        { "type" => "ObserverEnrollment" },
        { "type" => "TaEnrollment" },
        { "type" => "TeacherEnrollment" },
        { "type" => "DesignerEnrollment"}
      ]
      expect(helper.lms_user_role(enrollments)).to eq :professor
    end
  end
end
