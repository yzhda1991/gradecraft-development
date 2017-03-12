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
end
