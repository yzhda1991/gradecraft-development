# encoding: utf-8
require "spec_helper"

describe "assignments/_index_student" do

  let(:user) { double(:user, is_student?: true) }
  let(:view_context) { double(:view_context, current_user: user) }
  let(:presenter) { Assignments::StudentPresenter.new({ course: @course, assignment_types:
    @assignment_types, student: @student, view_context: view_context }) }

  before(:each) do
    @course = create(:course)
    @assignment_types = [create(:assignment_type, course: @course, max_points: 1000)]
    @assignment = create(:assignment, assignment_type: @assignment_types[0])
    @course.assignments << @assignment
    @student = create(:user, courses: [@course], role: :student)
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_student).and_return(@student)
    allow(view).to receive(:presenter).and_return presenter
  end

  it "shows the assignment type div" do
    render
    assert_select ".assignment_type", contains: "#{ @assignment_types[0].name }",  count: 1
  end

  it "shows the challenge div" do
    @challenge = create(:challenge, course: @course)
    @course.has_team_challenges = true
    @course.add_team_score_to_student = true
    @team = create(:team, course: @course)
    @team.students << @student
    render
    assert_select ".team-challenge", count: 1
  end

  it "does not show the challenge div if they're not added to student scores" do
    @challenge = create(:challenge, course: @course)
    @course.has_team_challenges = true
    @course.add_team_score_to_student = false
    @team = create(:team, course: @course)
    @team.students << @student
    render
    assert_select ".team-challenge", count: 0
  end

end
