require "rails_spec_helper"

describe LMSHelper do
  describe "#lms_user_match?" do
    let(:course) { create :course }
    let(:email) { "jimmy@example.com" }
    let(:membership) { create :student_course_membership, user: student, course: course }
    let(:student) { create :user, email: email }

    it "returns false if the user does not exist" do
      expect(helper.lms_user_match?("blah@blah.com", course)).to eq false
    end

    it "returns false if the user does not belong to the course" do
      student

      expect(helper.lms_user_match?(email, course)).to eq false
    end

    it "returns true if the user exists and belongs to the course" do
      membership

      expect(helper.lms_user_match?(email, course)).to eq true
    end
  end
end
