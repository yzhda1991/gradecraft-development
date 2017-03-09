# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "students/index" do
  let(:current_course) { create :course }
  let(:current_user) { create(:course_membership, :professor, course: current_course).user }
  let(:presenter) { Students::IndexPresenter.new({ course: current_course, current_user: current_user }) }
  let(:student1) { create(:course_membership, :student, course: course).user }
  let(:student2) { create(:course_membership, :student, course: course).user }

  before(:each) do
    allow(view).to receive(:current_course).and_return(current_course)
    allow(view).to receive(:presenter).and_return presenter
    allow(view).to receive(:term_for).with(:students).and_return "Students"
  end

  it "renders successfully" do
    render
  end
end
