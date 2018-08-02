describe Services::Actions::DestroysMembership do
  let(:membership) { create :course_membership, :student }

  it "expects the membership to destroy" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "destroys the membership" do
    described_class.execute membership: membership
    expect(CourseMembership.exists?(membership.id)).to eq false
  end

  it "skips the rest of the actions if the membership is not for a student" do
    admin_membership = create(:course_membership, :admin)
    result = described_class.execute membership: admin_membership
    expect(result).to be_skip_remaining
  end
end
