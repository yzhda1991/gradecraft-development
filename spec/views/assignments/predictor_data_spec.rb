# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "assignments/predictor_data" do

  before(:each) do
    clean_models
    @course = create(:course, assignment_term: "mission", pass_term: "paz", fail_term: "fayl")
    @assignment = create(:assignment, description: "...")
    @assignments = [@assignment]
    @student = create(:user)
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_user).and_return(@student)
  end

  it "responds with an array of assignments" do
    render
    @json = JSON.parse(response.body)
    expect(@json["assignments"].length).to eq(1)
  end

  it "adds attribute 'fixed' to the assignments" do
    render
    @json = JSON.parse(response.body)
    expect(@json["assignments"][0]["fixed"]).to eq(true)
  end

  it "includes the current student grade with the assignment" do
    @assignment.current_student_grade = { id: 1, pass_fail_status: "should not persist", score: 1000, predicted_score: 999 }
    render
    @json = JSON.parse(response.body)
    expect(@json["assignments"][0]["grade"]).to eq({ "id" => 1, "score" => 1000, "predicted_score" => 999 })
  end

  it "includes the pass fail status with the grade when the assignment is pass fail" do
    @assignment.current_student_grade = { id: 1, pass_fail_status: "passed", score: 1000, predicted_score: 999 }
    @assignment.update(pass_fail: true)
    render
    @json = JSON.parse(response.body)
    expect(@json["assignments"][0]["grade"]).to eq({ "id" => 1, "pass_fail_status" => "passed", "score" => 1000, "predicted_score" => 999 })
  end

  it "does not include assignments with no points" do
    @assignment.update(point_total: 0)
    render
    @json = JSON.parse(response.body)
    expect(@json["assignments"].length).to eq(0)
  end

  it "does include pass/fail assignments with no points" do
    @assignment.update(point_total: 0, pass_fail: true)
    render
    @json = JSON.parse(response.body)
    expect(@json["assignments"].length).to eq(1)
  end

  it "does not include assignments invisible to students" do
    @assignment.update(visible: false)
    render
    @json = JSON.parse(response.body)
    expect(@json["assignments"].length).to eq(0)
  end

  it "not include assignments in predictor if include_in_predictor is false" do
    @assignment.update(include_in_predictor: false)
    render
    @json = JSON.parse(response.body)
    expect(@json["assignments"].length).to eq(0)
  end

  describe "passes boolean states for icons" do
    it "adds is_required to model" do
      @assignment.update(required: true)
      render
      @json = JSON.parse(response.body)
      expect(@json["assignments"][0]["is_required"]).to be_truthy
    end

    it "adds has_info to model" do
      render
      @json = JSON.parse(response.body)
      expect(@json["assignments"][0]["has_info"]).to be_truthy
    end

    it "adds is_late to model" do
      allow(@assignment).to receive(:past?).and_return(true)
      @assignment.update(accepts_submissions: true)
      render
      @json = JSON.parse(response.body)
      expect(@json["assignments"][0]["is_late"]).to be_truthy
    end

    it "adds is_locked to model" do
      allow(@assignment).to receive(:is_unlocked_for_student?).and_return(false)
      render
      @json = JSON.parse(response.body)
      expect(@json["assignments"][0]["is_locked"]).to be_truthy
    end

    it "adds has_been_unlocked to model" do
      allow(@assignment).to receive(:is_unlocked_for_student?).and_return(true)
      allow(@assignment).to receive(:is_unlockable?).and_return(true)
      render
      @json = JSON.parse(response.body)
      expect(@json["assignments"][0]["has_been_unlocked"]).to be_truthy
    end

    it "adds is_a_condition to model" do
      allow(@assignment).to receive(:is_a_condition?).and_return(true)
      render
      @json = JSON.parse(response.body)
      expect(@json["assignments"][0]["is_a_condition"]).to be_truthy
    end
  end

  it "includes unlock keys when assignment is an unlock condition" do
    @badge = create(:badge)
    @unlock_key = create(:unlock_condition, unlockable: @badge, condition: @assignment)
    render
    @json = JSON.parse(response.body)
    expect(@json["assignments"][0]["unlock_keys"]).to eq(["#{@badge.name} is unlocked by #{@unlock_key.condition_state} #{@assignment.name}"])
  end

  it "includes unlock conditions when assignment is a unlockable" do
    @badge = create(:badge)
    @unlock_condition = create(:unlock_condition, unlockable: @assignment, unlockable_type: "Assignment", condition: @badge, condition_type: "Badge")
    render
    @json = JSON.parse(response.body)
    expect(@json["assignments"][0]["unlock_conditions"]).to eq(["#{@badge.name} must be #{@unlock_condition.condition_state}"])
  end

  it "includes the assigment score levels" do
    asl = create(:assignment_score_level, assignment: @assignment)
    render
    @json = JSON.parse(response.body)
    expect(@json["assignments"][0]["score_levels"]).to eq([{"name" => asl.name, "value" => asl.value}])
  end

  it "renders term for assignments, pass, and fail" do
    render
    @json = JSON.parse(response.body)
    expect(@json["term_for_assignment"]).to eq("mission")
    expect(@json["term_for_pass"]).to eq("paz")
    expect(@json["term_for_fail"]).to eq("fayl")
  end
end
