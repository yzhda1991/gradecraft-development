describe LMSHelper do
  describe "#lms_user_match?" do
    let(:course) { create :course }

    context "the user does not exist" do
      it "returns false" do
        expect(helper.lms_user_match?("blah@blah.com", "blah", course)).to eq false
      end
    end

    context "the user exists" do
      let(:email) { "jimmy@example.com" }
      let!(:student) { create :user, email: email, username: "jimmy" }

      context "when the user belongs to the course" do
        let!(:course_membership) { create :course_membership, :student, user: student, course: course }

        it "returns true if the user matches on username" do
          create :course_membership, :student, user: student, course: course
          expect(helper.lms_user_match?(nil, "jimmy", course)).to eq true
        end

        it "returns true if the user matches on email" do
          create :course_membership, :student, user: student, course: course
          expect(helper.lms_user_match?(email, nil, course)).to eq true
        end
      end

      context "when the user does not belong to the course" do
        it "returns false" do
          expect(helper.lms_user_match?(email, nil, course)).to eq false
        end
      end
    end
  end
end
