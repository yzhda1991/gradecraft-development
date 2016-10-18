# encoding: utf-8
require "rails_spec_helper"

describe "api/challenges/index" do
  before(:all) do
    @course = create(:course, challenge_term: "tsallenze")
    @student = create(:user)
  end
  before(:each) do
    @challenge = create(:challenge, description: "...")
    @challenges = [@challenge]
    allow(view).to receive(:current_course).and_return(@course)
  end

  it "responds with an array of challenges" do
    render
    @json = JSON.parse(response.body)
    expect(@json["data"].length).to eq(1)
  end

  it "does not include challenges invisible to students" do
    @challenge.update(visible: false)
    render
    @json = JSON.parse(response.body)
    expect(@json["data"].length).to eq(0)
  end

  it "adds the score levels if present into the challenge" do
    csl = create(:challenge_score_level, challenge: @challenge)
    render
    @json = JSON.parse(response.body)
    expect(@json["data"][0]["attributes"]["score_levels"]).to eq([{"name" => csl.name, "points" => csl.points}])
  end

  describe "passes boolean states for icons" do
    it "adds has_info to model" do

      render
      @json = JSON.parse(response.body)
      expect(@json["data"][0]["attributes"]["has_info"]).to be_truthy
    end
  end

  it "renders term for challenges" do
    render
    @json = JSON.parse(response.body)
    expect(@json["meta"]["term_for_challenges"]).to eq("Team tsallenzes")
  end

  it "includes update_predictions" do
    @update_predictions = true
    render
    @json = JSON.parse(response.body)
    expect(@json["meta"]["update_predictions"]).to be_truthy
  end

  describe "included" do
    it "contains the prediction" do
      create :student_course_membership, user: @student, course: @challenge.course
      prediction = create :predicted_earned_challenge, challenge: @challenge, student: @student
      @predicted_earned_challenges =
        PredictedEarnedChallenge.where(student_id: @student.id)
      render
      json = JSON.parse(response.body)
      expect(json["data"][0]["relationships"]["prediction"]).to eq(
        {"data"=>{"type"=>"predicted_earned_challenges", "id"=>prediction.id.to_s}}
      )
      expect(json["included"][0]["attributes"]).to eq(
        { "id" => prediction.id,
          "predicted_points" => prediction.predicted_points,
        }
      )
    end

    it "contains the current team grade" do
      team = create :team, course: @course
      grade = create :challenge_grade, challenge: @challenge, team: team, status: "Released"
      @grades = ChallengeGrade.where(challenge_id: @challenge.id)
      render
      json = JSON.parse(response.body)
      expect(json["data"][0]["relationships"]["grade"]).to eq(
        {"data"=>{"type"=>"challenge_grades", "id"=>grade.id.to_s}}
      )
      expect(json["included"][0]["attributes"]).to eq(
        { "id" => grade.id,
          "final_points" => grade.final_points,
          "score" => grade.score
        }
      )
    end
  end
end
