# encoding: utf-8
require 'rails_spec_helper'
include CourseTerms

describe "assignment_type_weights/predictor_data" do

  before(:all) do
    @course = create(:course, weight_term: "kapital")
    @assignment_types_weightable = [37,38,39]
    @total_weights = 6
    @close_at = "1234"
    @max_weights = 4
    @max_types_weighted = 2
    @default_weight = 1
    @update_weights = true
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
    render
    @json = JSON.parse(response.body)
  end

  it "responds with weightable assignment types" do
    expect(@json["weights"]["assignment_types_weightable"]).to eq([37,38,39])
  end

  it "includes course attributes related to assigment weights" do
    expect(@json["weights"]["total_weights"]).to eq(6)
    expect(@json["weights"]["close_at"]).to eq("1234")
    expect(@json["weights"]["max_weights"]).to eq(4)
    expect(@json["weights"]["max_types_weighted"]).to eq(2)
    expect(@json["weights"]["default_weight"]).to eq(1)
  end

  it "includes the flag to update weights" do
    expect(@json["update_weights"]).to be_truthy
  end

  it "includes the course term for weights" do
    expect(@json["term_for_weights"]).to eq("kapitals")
  end
end
