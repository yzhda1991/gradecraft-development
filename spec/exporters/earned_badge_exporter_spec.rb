require "active_record_spec_helper"
require "./app/exporters/earned_badge_exporter"

describe EarnedBadgeExporter do
  let(:course) { create :course }
  let(:students) { create_list :user, 2 }
  subject { EarnedBadgeExporter.new }

  describe "#earned_badges_for_course(earned_badges)" do
    it "generates an empty CSV if there are no earned badges" do
      csv = subject.earned_badges_for_course([])
      expect(csv).to include 'First Name,Last Name,Uniqname,Email,Badge ID,Badge Name,Feedback,Awarded Date'
    end
  end

end