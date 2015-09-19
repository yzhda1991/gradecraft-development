require 'spec_helper'

RSpec.describe AssignmentExportPresenter, type: :presenter do
  # intended to reorganize a simple collection of submissions
  # using the associated student as the cardinal object

  describe "submissions_by_student" do
    before do
      mock_students
      mock_submissions
      @submissions = submissions_by_id
      set_grouped_submission_expectation
    end

    subject do
      AssignmentExportPresenter.new({ submissions: @submissions }).
        submissions_grouped_by_student
    end

    it "should reorder the @submissions array by student" do
      expect(subject).to eq(@grouped_submission_expectation)
    end

    it "should use 'last_name_first_name-id' for the hash keys" do
      expect(subject.keys.first).to eq("bailey_ben-40")
    end

    it "should return an array of submissions for each student" do
      expect(subject["mccaffrey_mike-55"]).to eq([@submission2, @submission4])
    end
  end

  def mock_students
    @student1 = {first_name: "Ben", last_name: "Bailey", id: 40}
    @student2 = {first_name: "Mike", last_name: "McCaffrey", id: 55}
    @student3 = {first_name: "Dana", last_name: "Dafferty", id: 92}
  end

  def mock_submissions
    # create some mock submissions with students attached
    @submission1 = {id: 1, student: @student1}
    @submission2 = {id: 2, student: @student2}
    @submission3 = {id: 3, student: @student3}
    @submission4 = {id: 4, student: @student2}
  end

  def submissions_by_id
    [@submission1, @submission2, @submission3, @submission4]
  end

  def set_grouped_submission_expectation
      # expectation for #group_submissions_by_student
      @grouped_submission_expectation ||= {
        "bailey_ben-40" => [@submission1],
        "mccaffrey_mike-55" => [@submission2, @submission4],
        "dafferty_dana-92" => [@submission3]
      }
  end
end
