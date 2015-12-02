require "light-service"
require "active_record_spec_helper"
require "./app/services/cancels_course_membership/destroys_membership"

describe Services::Actions::DestroysMembership do
  let(:membership) { create :student_course_membership }

  it "expects the membership to destroy" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "destroys the membership" do
    described_class.execute membership: membership
    expect(CourseMembership.exists?(membership.id)).to eq false
  end
end
