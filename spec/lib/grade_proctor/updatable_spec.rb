require "./lib/grade_proctor"

describe GradeProctor::Updatable do
  let(:assignment) { double(:assignment, release_necessary?: true) }
  let(:grade) { double(:grade, assignment: assignment, student_id: 123,
                       is_graded?: true, is_released?: false) }
  let(:user) { double(:user, id: 123) }

  describe "#updatable?" do
    subject { GradeProctor.new(grade) }

    context "as a student" do
      xit "cannot update the grade"
    end

    context "as a professor" do
      xit "can update if they are the instructor for the course"
    end
  end
end
