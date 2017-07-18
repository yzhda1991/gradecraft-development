describe "api/grades/show" do
  let(:assignment) { create :assignment }
  let(:student) { create(:course_membership, :student).user }
  let(:grade) { create(:grade, student: student, assignment: assignment) }

  before(:each) do
    @grade = grade
  end

  it "responds with a grade" do
    render
    json = JSON.parse(response.body)
    expect(json["data"]["type"]).to eq("grades")
  end

  it "adds the attributes to the grade" do
    render
    json = JSON.parse(response.body)
    expect(json["data"]["attributes"]["id"]).to eq(@grade.id)
    expect(json["data"]["attributes"]["assignment_id"]).to eq(@grade.assignment_id)
    expect(json["data"]["attributes"]["student_id"]).to eq(@grade.student_id)
    expect(json["data"]["attributes"]["feedback"]).to eq(@grade.feedback)
    expect(json["data"]["attributes"]["status"]).to eq(@grade.status)
    expect(json["data"]["attributes"]["adjustment_points"]).to eq(@grade.adjustment_points)
    expect(json["data"]["attributes"]["adjustment_points_feedback"]).to eq(@grade.adjustment_points_feedback)
  end

  it "adds the threshold_points to meta data" do
    render
    json = JSON.parse(response.body)
    expect(json["meta"]["threshold_points"]).to eq(@grade.assignment.threshold_points)
  end
end
