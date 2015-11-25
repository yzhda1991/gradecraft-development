require "active_record_spec_helper"

describe ChallengeGrade do 
  subject { build(:challenge_grade) }

  context "validations", focus: true do
    it "is valid with a team, and a challenge" do
      expect(subject).to be_valid
    end
  end
end