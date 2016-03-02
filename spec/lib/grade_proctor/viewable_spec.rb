require "./lib/grade_proctor"

describe GradeProctor::Viewable do
  let(:assignment) { double(:assignment, release_necessary?: true) }
  let(:grade) { double(:grade, assignment: assignment, student_id: 123,
                       is_graded?: true, is_released?: false) }
  let(:user) { double(:user, id: 123) }

  describe "#viewable?" do
    subject { GradeProctor.new(grade) }

    context "as a student" do
      it "cannot view the grade if it's not assigned to them" do
        allow(grade).to receive(:student_id).and_return 456
        expect(subject).to_not be_viewable user
      end

      it "can view the grade if it's been released" do
        allow(grade).to receive(:is_released?).and_return true
        expect(subject).to be_viewable user
      end

      it "can view the grade if it's been graded and a release is not necessary" do
        allow(assignment).to receive(:release_necessary?).and_return false
        expect(subject).to be_viewable user
      end

      it "cannot view the grade if it's been graded and a release is necessary" do
        expect(subject).to_not be_viewable user
      end
    end
  end
end
