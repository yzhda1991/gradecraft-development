require "./app/models/null_grade"

describe NullGrade do
  subject { NullGrade.new }

  it "has a nil score" do
    expect(subject.score).to be_nil
  end

  it "has a nil raw score" do
    expect(subject.raw_score).to be_nil
  end

  it "has a nil final score" do
    expect(subject.final_score).to eq(nil)
  end

  it "has nil feedback" do
    expect(subject.feedback).to be_nil
  end

  it "has a nil pass/fail status" do
    expect(subject.pass_fail_status).to eq(nil)
  end

  it "has a nil status" do
    expect(subject.status).to eq(nil)
  end

  it "has a nil updated at timestamp" do
    expect(subject.updated_at).to eq(nil)
  end

  it "has a nil graded at timestamp" do
    expect(subject.graded_at).to eq(nil)
  end

  it "has a team id of zero" do
    expect(subject.team_id).to eq(0)
  end

  it "is student visible" do
    expect(subject).to be_is_student_visible
  end

  it "can have an assigned predicted score" do
    expect(subject.predicted_score).to eq(0)
    subject.predicted_score = 100
    expect(subject.predicted_score).to eq 100
  end

  it "has a zero id" do
    expect(subject.id).to eq(0)
  end

  it "returns 555 for the point total" do
    expect(subject.point_total).to eq(555)
  end

  it "handles queries for assignments with closed submissions" do
    expect(subject.assignment.submissions_have_closed?).to be_falsey
  end

  it "handles queries for assignments accepting submissions" do
    expect(subject.assignment.accepts_submissions?).to be_falsey
  end

  it "returns a null student for student" do
    expect(subject.student.class).to eq(NullStudent)
  end
end
