# encoding: utf-8
require "rails_spec_helper"

describe "api/grades/show" do
  before(:all) do
    world = World.create.with(:course, :assignment, :student, :grade)

    # Expected instance variables on render:
    @grade = world.grade
    @grade_status_options = ["In Progress","Graded", "Released"]
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
    expect(json["data"]["attributes"]["points_adjustment"]).to eq(@grade.points_adjustment)
    expect(json["data"]["attributes"]["points_adjustment_feedback"]).to eq(@grade.points_adjustment_feedback)
  end

  it "adds grading status options to meta data" do
    render
    json = JSON.parse(response.body)
    expect(json["meta"]["grade_status_options"]).to eq(@grade_status_options)
  end
end
