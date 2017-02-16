require "spec_helper"

describe EarnedBadgeAnnouncement do
  let(:announcement) { Announcement.unscoped.last }
  let(:course) { earned_badge.course }
  let(:earned_badge) { create :earned_badge, awarded_by: user }
  let(:user) { create :user }

  describe ".create" do
    skip "pending semester end"
    # it "creates an announcement for the earned badge" do
    #   expect { described_class.create earned_badge }.to change { Announcement.count }.by 1
    #   expect(announcement.course).to eq earned_badge.course
    #   expect(announcement.author).to eq user
    #   expect(announcement.recipient).to eq earned_badge.student
    #   expect(announcement.title).to \
    #     eq "#{course.course_number} - You've earned a new #{course.badge_term}!"
    #   expect(announcement.body).to include \
    #     "<p>Congratulations #{earned_badge.student.first_name}!</p>"
    #   expect(announcement.body).to include \
    #     "<p>You've earned the #{earned_badge.badge.name} #{course.badge_term}.</p>"
    #   expect(announcement.body).to include \
    #     "<p>Check out your new "\
    #       "<a href='http://localhost:5000/badges'>badge</a>.</p>"
    # end
  end
end
