describe "api/assignment_types/index" do

  before(:all) do
    @course = create(:course, :has_multipliers,
      assignment_term: "mission",
      total_weights: 6,
      weights_close_at: Time.now,
      max_weights_per_assignment_type: 4,
      max_assignment_types_weighted: 2
    )
    assignment_type = create(:assignment_type, course: @course, student_weightable: true, has_max_points: true, max_points: 1234)
    @assignment_types = [assignment_type]
    @student = create(:user)
  end

  before(:each) do
    allow(@student).to receive(:weight_for_assignment_type).and_return(777)
    allow(@assignment_types.first).to receive(:final_points_for_student).and_return(888)
    allow(view).to receive(:current_course).and_return(@course)
    render
    @json = JSON.parse(response.body)
  end

  it "responds with an array of assignment_types" do
    expect(@json["data"].length).to eq(1)
  end

  it "includes the assignment_type total points" do
    expect(@json["data"].first["attributes"]["total_points"]).to eq(0)
  end

  it "includes the assignment_type final points summed for student" do
    expect(@json["data"].first["attributes"]["final_points_for_student"]).to eq(888)
  end

  it "renders the student weight" do
    expect(@json["data"].first["attributes"]["student_weight"]).to eq(777)
  end

  it "renders the term for assignment_type" do
    expect(@json["meta"]["term_for_assignment_type"]).to eq("mission type")
  end

  it "renders the weighting information from the current_course" do
    expect(@json["meta"]["total_weights"]).to eq(@course.total_weights)
    expect(@course.weights_close_at.to_json).to include(@json["meta"]["weights_close_at"])
    expect(@json["meta"]["max_weights_per_assignment_type"]).to eq(@course.max_weights_per_assignment_type)
    expect(@json["meta"]["max_assignment_types_weighted"]).to eq(@course.max_assignment_types_weighted)
  end
end
