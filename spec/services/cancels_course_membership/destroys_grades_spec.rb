describe Services::Actions::DestroysGrades do
  let(:course) { membership.course }
  let(:membership) { create :course_membership, :student }
  let(:student) { membership.user }

  it "expects the membership to find the grades to destroy" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "destroys the grade" do
    another_grade = create :grade, student: student
    course_grade = create :grade, student: student, course: course
    described_class.execute membership: membership
    expect(student.reload.grades).to eq [another_grade]
  end

  it "destroys the rubric grades for the course assignments" do
    course_assignment = create :assignment, course: course
    another_grade = create :criterion_grade, student: student
    course_grade = create :criterion_grade, assignment: course_assignment,
      student: student
    described_class.execute membership: membership
    expect(CriterionGrade.for_student(membership.user)).to eq [another_grade]
  end
end
