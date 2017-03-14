describe CourseMembershipBuilder do
  let(:builder) { create :user }
  let(:user) { create :user }
  let!(:membership) { create :course_membership, :professor, user: builder }

  subject { described_class.new(builder) }

  describe "#build_for" do
    it "builds memberships for courses the builder has access to" do
      subject.build_for(user)
      expect(user.course_memberships.map(&:course)).to eq [membership.course]
      expect(user.course_memberships.map(&:role)).to eq ["student"]
    end

    it "optionally builds a membership with a specific role" do
      subject.build_for(user, "professor")
      expect(user.course_memberships.map(&:role)).to eq ["professor"]
    end

    it "does not build duplicated memberships" do
      user.course_memberships.create course_id: membership.course_id
      subject.build_for(user)
      expect(user.course_memberships.map(&:course)).to eq [membership.course]
    end
  end
end
