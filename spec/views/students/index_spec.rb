# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "students/index" do
  let(:course) { create :course }
  let(:current_user) { create(:professor_course_membership, course: course).user }
  let(:presenter) { Students::IndexPresenter.new({ course: course, current_user: current_user }) }
  let(:student1) { create(:student_course_membership, course: course).user }
  let(:student2) { create(:student_course_membership, course: course).user }

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_user).and_return(@student_1)
    allow(view).to receive(:presenter).and_return presenter
    allow(view).to receive(:term_for).with(:students).and_return "Students"
  end

  it "renders successfully" do
    render
  end
end
