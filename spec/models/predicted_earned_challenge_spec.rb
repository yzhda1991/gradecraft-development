#predictedEarnedBadge_spec.rb
require 'rails_spec_helper'

describe PredictedEarnedChallenge do

  before do
    @predicted_earned_challenge = create(:predicted_earned_challenge)
  end

  subject { @predicted_earned_challenge }

  it { is_expected.to respond_to("student_id")}
  it { is_expected.to respond_to("challenge_id")}
  it { is_expected.to respond_to("points_earned")}

  it { is_expected.to be_valid }

end
