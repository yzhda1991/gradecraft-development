require 'spec_helper'

describe Announcement do
  describe "default scope" do
    it "should return the newest announcements first" do
      announcement1 = create :announcement
      announcement2 = create :announcement
      expect(Announcement.all).to eq [announcement2, announcement1]
    end
  end

  describe "authorization" do
    let(:course) { create :course }
    let(:user) { create :user }
    subject { build :announcement, course: course }

    it "is viewable by any user associated the course" do
      expect(user.can_view?(subject)).to be_false
      CourseMembership.create user_id: user.id, course_id: course.id, role: "student"
      expect(user.can_view?(subject)).to be_true
    end

    it "is creatable by any staff for the course" do
      expect(user.can_create?(subject)).to be_false
      CourseMembership.create user_id: user.id, course_id: course.id, role: "professor"
      expect(user.can_create?(subject)).to be_true
    end

    it "is not creatable by a student" do
      CourseMembership.create user_id: user.id, course_id: course.id, role: "student"
      expect(user.can_create?(subject)).to be_false
    end

    it "is not creatable by staff in another course" do
      new_course = create :course
      CourseMembership.create user_id: user.id, course_id: new_course.id, role: "professor"
      expect(user.can_create?(subject)).to be_false
    end

    it "is updatable by the author" do
      expect(user.can_update?(subject)).to be_false
      subject.update_attribute(:author_id, user.id)
      expect(user.can_update?(subject)).to be_true
    end

    it "is destroyable by the author" do
      expect(user.can_destroy?(subject)).to be_false
      subject.update_attribute(:author_id, user.id)
      expect(user.can_destroy?(subject)).to be_true
    end
  end

  describe "validations" do
    it "requires a title" do
      announcement = build :announcement, title: ""
      expect(announcement).to_not be_valid
      expect(announcement.errors[:title]).to include "can't be blank"
    end

    it "requires a body" do
      announcement = build :announcement, body: ""
      expect(announcement).to_not be_valid
      expect(announcement.errors[:body]).to include "can't be blank"
    end

    it "requires a course" do
      announcement = build :announcement, course_id: nil
      expect(announcement).to_not be_valid
      expect(announcement.errors[:course]).to include "can't be blank"
    end

    it "requires an author" do
      announcement = build :announcement, author_id: nil
      expect(announcement).to_not be_valid
      expect(announcement.errors[:author]).to include "can't be blank"
    end
  end

  describe "#abstract" do
    let(:body) do <<-BODY
        I am honored to be with you today at your commencement from one of the finest universities in the world. I never graduated from college. Truth be told, this is the closest I've ever gotten to a college graduation. Today I want to tell you three stories from my life. That's it. No big deal. Just three stories.

        The first story is about connecting the dots.

        I dropped out of Reed College after the first 6 months, but then stayed around as a drop-in for another 18 months or so before I really quit. So why did I drop out?
      BODY
    end
    subject { Announcement.new body: body }

    it "returns the first 25 words by default" do
      expect(subject.abstract).to eq "I am honored to be with you today at your commencement from one of the finest universities in the world. I never graduated from college."
    end

    it "returns the specified number of words" do
      expect(subject.abstract(3)).to eq "I am honored"
    end
  end

  describe "#deliver!" do
    let(:course) { create :course }
    let(:student) { create :user }
    subject { create :announcement, course: course }

    before(:each) do
      CourseMembership.create! course_id: course.id,
        user_id: student.id, role: "student"
    end

    it "sends an email to all the students in the course" do
      expect { subject.deliver! }.to \
        change { ActionMailer::Base.deliveries.count }.by 1
    end
  end
end
