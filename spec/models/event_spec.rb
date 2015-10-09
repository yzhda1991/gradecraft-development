# TODO: Redefine the concerns here so we don't have to require a rabbit hole. There should be a better way. This may be affected by test order. We'll come back to this
module UploadsMedia; end
module UploadsThumbnails; end

require "active_record_spec_helper"
require "./app/models/event"

describe Event do
  subject { build(:event) }

  describe "validations" do
    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end
  end
end
