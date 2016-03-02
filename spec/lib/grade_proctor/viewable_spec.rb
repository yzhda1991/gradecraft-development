require "./lib/grade_proctor"

describe GradeProctor::Viewable do
  let(:grade) { double(:grade, student_id: 123, is_released?: false) }
  let(:user) { double(:user, id: 123) }

  describe "#viewable?" do
    subject { GradeProctor.new(grade) }

    context "as a student" do
      it "cannot view the grade if it's not assigned to them" do
        expect(subject).to_not be_viewable user
      end

      it "can view the grade if it's been released" do
        allow(grade).to receive(:is_released?).and_return true
        expect(subject).to be_viewable user
      end

      xit "can view the grade if it's been graded and a release is not necessary"
      xit "cannot view the grade if it's been graded and a release is necessary"
    end
  end
end
