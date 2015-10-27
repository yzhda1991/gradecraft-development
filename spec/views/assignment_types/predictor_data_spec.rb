# encoding: utf-8
require 'rails_spec_helper'
include CourseTerms

describe "assignment_types/predictor_data" do
  before(:all) do
    @course = create(:course, assignment_term: "mission")
    assignment_type = create(:assignment_type, course: @course, student_weightable: true, max_points: 1234)
    @assignment_types = [assignment_type]
    @student = create(:user)
  end

  before(:each) do
    allow(@student).to receive(:weight_for_assignment_type).and_return(777)
    allow(view).to receive(:current_course).and_return(@course)
    render
    @json = JSON.parse(response.body)
  end

  it "responds with an array of assignment_types" do
    expect(@json["assignment_types"].length).to eq(1)
  end

  it "includes the assignment_type total points" do
    expect(@json["assignment_types"].first["total_points"]).to eq(1234)
  end

  it "renders the student weight" do
    expect(@json["assignment_types"].first["student_weight"]).to eq(777)
  end

  it "renders the term for assignment_type" do
    expect(@json["term_for_assignment_type"]).to eq("mission type")
  end
end
