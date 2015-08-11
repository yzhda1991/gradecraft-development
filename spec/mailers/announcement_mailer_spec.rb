require 'spec_helper'

describe AnnouncementMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:announcement) { create :announcement, author: author }
  let(:author) { create :user }
  let(:student) { create :user }

  describe ".announcement_email" do
    before(:each) do
      AnnouncementMailer.announcement_email(announcement, student).deliver_now
    end

    it "is sent from the author's email" do
      expect(email.from).to eq [author.email]
    end

    it "is sent to the student's email" do
      expect(email.to).to eq [student.email]
    end

    it "has an appropriate subject" do
      expect(email.subject).to eq announcement.title
    end

    it "has the announcement abstract" do
      expect(email.body).to include announcement.abstract
    end

    it "has the announcement link" do
      expect(email.body).to include announcement_url(announcement)
    end
  end
end
