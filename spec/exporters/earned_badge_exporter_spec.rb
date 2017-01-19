require "active_record_spec_helper"
require "./app/exporters/earned_badge_exporter"

describe EarnedBadgeExporter do
  let(:course) { create :course }
  let(:students) { create_list :user, 2 }
  subject { EarnedBadgeExporter.new }

  describe "#earned_badges_for_course(earned_badges)" do
    it "generates an empty CSV if there are no earned badges" do
      csv = subject.earned_badges_for_course([])
      expect(csv).to include "First Name,Last Name,Uniqname,Email,Badge ID,Badge Name,Feedback,Awarded Date\n"
    end

    it "generates a CSV of earned badges" do
      @student = create(:user, courses: [course], role: :student)
      @badge = create(:badge, course: course)
      @earned_badge = create(:earned_badge, badge_id: @badge.id, student_id: @student.id, course_id: course.id)
      @earned_badges = course.earned_badges
      csv = CSV.new(subject.earned_badges_for_course(@earned_badges)).read
      expect(csv.length).to eq 2
      expect(csv[1][0]).to eq @student.first_name
      expect(csv[1][1]).to eq @student.last_name
      expect(csv[1][2]).to eq @student.username
      expect(csv[1][3]).to eq @student.email
      expect(csv[1][4]).to eq "#{@badge.id}"
      expect(csv[1][5]).to eq @earned_badge.name
      expect(csv[1][6]).to eq @earned_badge.feedback
      expect(csv[1][7]).to eq @earned_badge.created_at.to_formatted_s(:db)
    end
  end

end
