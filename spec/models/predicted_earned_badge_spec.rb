#predictedEarnedBadge_spec.rb
require 'rails_spec_helper'

describe PredictedEarnedBadge do

  before do
    @predicted_earned_badge = create(:predicted_earned_badge)
  end

  subject { @predicted_earned_badge }

  it { is_expected.to respond_to("student_id")}
  it { is_expected.to respond_to("badge_id")}
  it { is_expected.to respond_to("times_earned")}

  it { is_expected.to be_valid }

  it "caluculates the total points predicted" do
    expect(@predicted_earned_badge.total_predicted_points).to eq(@predicted_earned_badge.times_earned * @predicted_earned_badge.badge.point_total)
  end

  context "when the badge has been earned by student" do

    before do
      3.times { create(:earned_badge, badge: @predicted_earned_badge.badge, student: @predicted_earned_badge.student, student_visible: true, course: @predicted_earned_badge.badge.course )}
      @predicted_earned_badge.update(times_earned: 1)
    end

    it "reports the actual times the student earned a badge" do
      expect(@predicted_earned_badge.actual_times_earned).to eq(3)
    end

    it "reports the predicted times earned taking into account the actual times earned" do
      expect(@predicted_earned_badge.times_earned).to eq(1)
      expect(@predicted_earned_badge.times_earned_including_actual).to eq(3)
    end
  end
end
