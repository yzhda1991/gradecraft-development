require "active_record_spec_helper"
require "./app/models/predicted_assignment_collection"

describe PredictedAssignmentCollection do
  let(:assignment1) { create :assignment }
  let(:assignment2) { create :assignment }
  let(:assignments) { Assignment.where(id: [assignment1.id, assignment2.id]) }
  let(:user) { double(:user) }

  describe "#initialize" do

    it "requires assignments and a user as the context" do
      subject = described_class.new assignments, user
      expect(subject.assignments.size).to eq assignments.size
      expect(subject.user).to eq user
    end

    it "plucks the assignment fields it exposes" do
      subject = described_class.new assignments, user
      assignment = subject.assignments.first
      [:accepts_resubmissions_until,
       :accepts_submissions,
       :accepts_submissions_until,
       :assignment_type_id,
       :course_id,
       :description,
       :due_at,
       :grade_scope,
       :id,
       :include_in_predictor,
       :name,
       :open_at,
       :pass_fail,
       :point_total,
       :points_predictor_display,
       :position,
       :release_necessary,
       :required,
       :resubmissions_allowed,
       :student_logged,
       :thumbnail,
       :use_rubric,
       :visible,
       :visible_when_locked].each do |attribute|
         expect(assignment).to respond_to attribute
       end
    end
  end

  describe "#each" do
    it "enumerates over the assignments and creates predicted assignments" do
      subject = described_class.new assignments, user
      subject.each do |assignment|
        expect(assignment).to be_instance_of PredictedAssignment
      end
    end
  end
end
