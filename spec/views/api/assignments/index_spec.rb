describe "api/assignments/index" do
  before(:all) do
    @course = create(:course, assignment_term: "mission", pass_term: "paz", fail_term: "fayl")
    @student = create(:user)
  end

  before(:each) do
    @assignment = create(:assignment, description: "...", course: @course)
    @assignments = [@assignment]
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_user).and_return(@student)
  end

  it "responds with an array of assignments" do
    render
    json = JSON.parse(response.body)
    expect(json["data"].length).to eq(1)
  end

  it "includes the pass fail status with the grade when the assignment is pass fail" do
    create :course_membership, :student, user: @student, course: @assignment.course
    grade = create :student_visible_grade, assignment: @assignment, student: @student,
      course: @assignment.course, pass_fail_status: "passed", raw_points: 1000,
      score: 1000
    @grades = Grade.where(assignment_id: @assignment.id)
    @assignment.update(pass_fail: true)
    render
    json = JSON.parse(response.body)
    expect(json["included"][0]["attributes"]["pass_fail_status"]).to eq("passed")
  end

  it "does include assignments with no points" do
    @assignment.update(full_points: 0)
    render
    json = JSON.parse(response.body)
    expect(json["data"].length).to eq(1)
  end

  it "does include pass/fail assignments with no points" do
    @assignment.update(full_points: 0, pass_fail: true)
    render
    json = JSON.parse(response.body)
    expect(json["data"].length).to eq(1)
  end

  it "does not include assignments invisible to students" do
    @assignment.update(visible: false)
    render
    json = JSON.parse(response.body)
    expect(json["data"].length).to eq(0)
  end

  describe "passes boolean states for icons" do
    it "adds is_required to model" do
      @assignment.update(required: true)
      render
      json = JSON.parse(response.body)
      expect(json["data"][0]["attributes"]["is_required"]).to be_truthy
    end

    it "adds has_info to model" do
      render
      json = JSON.parse(response.body)
      expect(json["data"][0]["attributes"]["has_info"]).to be_truthy
    end

    it "adds is_late to model" do
      @assignment.update_attributes(accepts_submissions: true, due_at: 2.days.ago)
      render
      json = JSON.parse(response.body)
      expect(json["data"][0]["attributes"]["is_late"]).to be_truthy
    end

    it "adds is_locked to model" do
      allow_any_instance_of(Assignment).to \
        receive(:is_unlocked_for_student?).and_return(false)
      render
      json = JSON.parse(response.body)
      expect(json["data"][0]["attributes"]["is_locked"]).to be_truthy
    end

    it "adds has_been_unlocked to model" do
      allow_any_instance_of(Assignment).to \
        receive(:is_unlockable?).and_return(true)
      allow_any_instance_of(Assignment).to \
        receive(:is_unlocked_for_student?).and_return(true)
      render
      json = JSON.parse(response.body)
      expect(json["data"][0]["attributes"]["has_been_unlocked"]).to be_truthy
    end

    it "adds is_a_condition to model" do
      allow_any_instance_of(Assignment).to \
        receive(:is_a_condition?).and_return(true)
      render
      json = JSON.parse(response.body)
      expect(json["data"][0]["attributes"]["is_a_condition"]).to be_truthy
    end

    it "adds is_earned_by_group to model" do
      allow_any_instance_of(Assignment).to \
        receive(:grade_scope).and_return("Group")
      render
      @json = JSON.parse(response.body)
      expect(@json["data"][0]["attributes"]["is_earned_by_group"]).to be_truthy
    end
  end

  it "includes unlock keys when assignment is an unlock condition" do
    badge = create(:badge)
    unlock_key = create(:unlock_condition, unlockable: badge, condition: @assignment, condition_state: 'Grade Earned')
    render
    json = JSON.parse(response.body)
    expect(json["data"][0]["attributes"]["unlock_keys"]).to eq(["Earning a grade for it unlocks the #{badge.name} Badge"])
  end

  it "includes unlock conditions when assignment is a unlockable" do
    badge = create(:badge)
    unlock_condition = create(:unlock_condition, unlockable: @assignment, unlockable_type: "Assignment", condition: badge, condition_type: "Badge")
    render
    json = JSON.parse(response.body)
    expect(json["data"][0]["attributes"]["unlock_conditions"]).to eq(["Earn the #{badge.name} Badge"])
  end

  it "includes the assignment score levels" do
    asl = create(:assignment_score_level, assignment: @assignment)
    render
    json = JSON.parse(response.body)
    expect(json["data"][0]["attributes"]["score_levels"]).to eq([{"id"=> asl.id, "name" => asl.name, "points" => asl.points}])
  end

  describe "included" do
    it "contains the grade" do
      create :course_membership, :student, user: @student, course: @assignment.course
      grade = create :student_visible_grade, assignment: @assignment, student: @student,
        course: @assignment.course, pass_fail_status: nil,
        raw_points: 1000, score: 1000
      @grades = Grade.where(assignment_id: @assignment.id)
      render
      json = JSON.parse(response.body)
      expect(json["data"][0]["relationships"]["grade"]).to eq(
        {"data"=>{"type"=>"grades", "id"=>grade.id.to_s}}
      )
      expect(json["included"][0]["attributes"]).to eq(
        { "id" => grade.id,
          "final_points" => 1000,
          "score" => 1000,
          "is_excluded" => false,
          "pass_fail_status" => nil
        }
      )
    end

    it "contains the prediction" do
      create :course_membership, :student, user: @student, course: @assignment.course
      prediction = create :predicted_earned_grade, assignment: @assignment, student: @student
      @predicted_earned_grades =
        PredictedEarnedGrade.where(assignment_id: @assignment.id, student_id: @student.id)
      render
      json = JSON.parse(response.body)
      expect(json["data"][0]["relationships"]["prediction"]).to eq(
        {"data"=>{"type"=>"predicted_earned_grades", "id"=>prediction.id.to_s}}
      )
      expect(json["included"][0]["attributes"]).to eq(
        { "id" => prediction.id,
          "predicted_points" => prediction.predicted_points,
        }
      )
    end
  end

  it "renders term for assignments, pass, and fail" do
    render
    json = JSON.parse(response.body)
    expect(json["meta"]["term_for_assignment"]).to eq("mission")
    expect(json["meta"]["term_for_pass"]).to eq("paz")
    expect(json["meta"]["term_for_fail"]).to eq("fayl")
  end
end
