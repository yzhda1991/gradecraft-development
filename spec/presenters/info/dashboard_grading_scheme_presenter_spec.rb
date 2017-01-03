require "active_record_spec_helper"
require "./app/presenters/info/dashboard_grading_scheme_presenter.rb"

describe Info::DashboardGradingSchemePresenter do
  before do 
    @course = create(:course)
    @student = create(:user)
    @grade_scheme_element_1 = create(:grade_scheme_element_high, course: @course)
    @grade_scheme_element_2 = create(:grade_scheme_element_low, course: @course)  
    @grade_scheme_element_3 = create(:grade_scheme_element_highest, course: @course, lowest_points: 20001, highest_points: 30000)
    @course_membership = create(:course_membership, :student, user: @student, course: @course, score: 20000, earned_grade_scheme_element_id: @grade_scheme_element_1.id)
  end
  
  subject { described_class.new course: @course, student: @student }
  
  describe "#score_for_course" do
    it "returns the student's score for this course" do
      expect(subject.score_for_course).to eq 20000
    end
  end
  
  describe "#course_elements" do 
    it "returns the grading scheme elements in the course" do 
      expect(subject.course_elements).to eq([@grade_scheme_element_2, @grade_scheme_element_1, @grade_scheme_element_3])
    end
  end
  
  describe "#first_element" do 
    it "returns the first item in the grading scheme" do 
      expect(subject.first_element).to eq(@grade_scheme_element_2)
    end
  end
  
  describe "#current_element" do 
    it "returns the element the student is currently on" do 
      expect(subject.current_element).to eq(@grade_scheme_element_1)
    end
  end
  
  describe "#next_element" do 
    it "returns the next element the student needs to achieve" do 
      expect(subject.next_element).to eq(@grade_scheme_element_3)
    end
  end
  
  describe "#previous_element" do 
    it "returns the previous_element the student earned" do 
      expect(subject.previous_element).to eq(@grade_scheme_element_2)
    end
  end
  
  describe "#points_to_next_level" do 
    it "returns the number of points the student needs to earn to get to the next level" do 
      expect(subject.points_to_next_level).to eq 1
    end
  end
  
  describe "#progress_percent" do 
    it "returns the perentage completion of the current level" do 
      expect(subject.progress_percent).to eq 100.00
    end
  end
end
