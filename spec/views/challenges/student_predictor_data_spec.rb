# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "challenges/predictor_data" do

  before(:each) do
    clean_models
    @course = create(:course, challenge_term: "tsallenze")
    @challenge = create(:challenge, description: "...")
    @challenges = [@challenge]
    @student = create(:user)
    allow(view).to receive(:current_course).and_return(@course)
  end

  it "responds with an array of challenges" do
    render
    @json = JSON.parse(response.body)
    expect(@json["challenges"].length).to eq(1)
  end

  it "does not include challenges invisible to students" do
    @challenge.update(visible: false)
    render
    @json = JSON.parse(response.body)
    expect(@json["challenges"].length).to eq(0)
  end

  it "adds the student predicted earned challenge info to the challenge" do
    allow(@challenge).to receive(:prediction).and_return({ id: 5, points_earned: 3 })
    render
    @json = JSON.parse(response.body)
    expect(@json["challenges"][0]["prediction"]).to eq({ "id" => 5, "points_earned" => 3 })
  end

  it "adds the score levels if present into the challenge" do
    csl = create(:challenge_score_level, challenge: @challenge)
    render
    @json = JSON.parse(response.body)
    expect(@json["challenges"][0]["score_levels"]).to eq([{"name" => csl.name, "value" => csl.value}])
  end

  it "adds the student grade into to the challenge" do
    allow(@challenge).to receive(:grade).and_return({ total_points: 555, score: 444, points_earned: 444 })
    render
    @json = JSON.parse(response.body)
    expect(@json["challenges"][0]["grade"]).to eq({ "total_points" => 555, "score" => 444, "points_earned" => 444 })
  end

  describe "passes boolean states for icons" do
    it "adds has_info to model" do
      @challenge.update(required: true)
      render
      @json = JSON.parse(response.body)
      expect(@json["challenges"][0]["has_info"]).to be_truthy
    end
  end

  it "renders term for challenges" do
    render
    @json = JSON.parse(response.body)
    expect(@json["term_for_challenges"]).to eq("team tsallenzes")
  end

  it "includes update_challenges" do
    @update_challenges = true
    render
    @json = JSON.parse(response.body)
    expect(@json["update_challenges"]).to be_truthy
  end
end
