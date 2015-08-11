require 'spec_helper'

describe Announcement do
  describe "default scope" do
    it "should return the newest announcements first" do
      announcement1 = create :announcement
      announcement2 = create :announcement
      expect(Announcement.all).to eq [announcement2, announcement1]
    end
  end
end
