require 'spec_helper'

describe Announcement do
  describe "default scope" do
    it "should return the newest announcements first" do
      announcement1 = create :announcement
      announcement2 = create :announcement
      expect(Announcement.all).to eq [announcement2, announcement1]
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
end
