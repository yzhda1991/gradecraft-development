# encoding: utf-8
require 'rails_spec_helper'
include CourseTerms

describe "grade_scheme_elements/predictor_data" do
  before(:all) do
    @grade_scheme_element = create(:grade_scheme_element_high)
    @grade_scheme_elements = [@grade_scheme_element]
    @total_points = 10000
  end
  before(:each) do
    render
    @json = JSON.parse(response.body)
  end

  it "responds with total_points" do
    expect(@json["total_points"]).to eq(10000)
  end

  it "responds with an array of grade_scheme_elements including name" do
    expect(@json["grade_scheme_elements"].length).to eq(1)
    expect(@json["grade_scheme_elements"][0]["name"]).to eq(@grade_scheme_element.name)
  end
end
