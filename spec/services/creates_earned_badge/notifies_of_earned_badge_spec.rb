require "rails_spec_helper"
require "./app/services/creates_earned_badge/notifies_of_earned_badge"

describe Services::Actions::NotifiesOfEarnedBadge , focus: true do
  let(:course) { earned_badge.course }
  let(:delivery) { double(:email, deliver_now: nil) }
  let(:earned_badge) { create :earned_badge, awarded_by: user }
  let(:user) { create :user }

  it "expects an earned badge to send the notification about" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  context "with a badge that is student visible" do

    it "sends a notification to the student of the newly awarded badge" do
      expect(delivery).to receive(:deliver_now)
      expect(NotificationMailer).to \
        receive(:earned_badge_awarded).with(earned_badge.id).and_return delivery
      described_class.execute earned_badge: earned_badge
    end

    it "creates an announcement for the student" do
      allow(NotificationMailer).to receive(:earned_badge_awarded).and_return delivery

      expect { described_class.execute earned_badge: earned_badge }.to \
        change { Announcement.count }.by 1

      announcement = Announcement.unscoped.last

      expect(announcement.course).to eq earned_badge.course
      expect(announcement.author).to eq user
      expect(announcement.title).to \
        eq "#{course.course_number} - You've earned a new #{course.badge_term}!"
      expect(announcement.body).to include \
        "<p>Congratulations #{earned_badge.student.first_name}!</p>"
      expect(announcement.body).to include \
        "<p>You've earned the #{earned_badge.badge.name} #{course.badge_term}.</p>"
      expect(announcement.body).to include \
        "<p>Check out your new "\
        "<a href='http://localhost:5000/courses/#{course.id}/badges/#{earned_badge.badge.id}/"\
        "earned_badges/#{earned_badge.id}'>badge</a>.</p>"
    end
  end

  context "with a badge that is not student visible" do
    before { earned_badge.update_attributes(grade: (create :unreleased_grade)) }

    it "does not send the notification" do
      expect(NotificationMailer).to_not receive(:earned_badge_awarded)
      described_class.execute earned_badge: earned_badge
    end

    it "does not create an announcement for the student" do
      expect { described_class.execute earned_badge: earned_badge }.to_not \
        change { Announcement.count }
    end
  end
end

