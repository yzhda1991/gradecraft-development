describe AssignmentProctor do
  let(:assignment) { build_stubbed :assignment, course: course, visible: false }
  let(:user) { build_stubbed :user }
  let(:course) { build_stubbed :course }
  let(:subject) { described_class.new assignment }

  describe "#viewable?" do
    context "as an instructor" do
      let(:user) { build_stubbed :user, courses: [course], role: :admin }
      it "returns true" do
        expect(subject.viewable?(user)).to eq true
      end
    end

    context "as a student" do
      let(:user) { build_stubbed :user, courses: [course], role: :student }
      it "returns false" do
        expect(subject.viewable?(user)).to eq false
      end
    end
  end
end
