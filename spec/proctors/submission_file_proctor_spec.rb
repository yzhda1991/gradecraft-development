require 'active_record_spec_helper'

require '../../app/proctors/submission_file_proctor'

describe SubmissionFileProctor do
  it "should have a readable submission_file" do
  end

  describe "#initialize" do
    it "accepts a submission file and set it to @submission_file" do
    end
  end

  describe "#downloadable?" do
    it "returns an error if :user and :course aren't given" do
    end

    context "submission course id doesn't match the course id" do
      it "returns false" do
      end
    end

    context "user is staff for the given course" do
      it "returns true" do
      end
    end

    context "assignment is individual" do
      context "the submission's student_id matches the given user's id" do
        it "returns true" do
        end
      end

      context "the submission's student_id doesn't match the given user's id" do
        it "returns false" do
        end
      end
    end

    context "assignment is not individual but has groups" do
      context "user is in the group that owns the submission" do
        it "returns true" do
        end
      end

      context "there is no group for the user for the given assignment" do
      end

      context "there's a group but it isn't the same one on the submission" do
      end
    end

    it "returns false if no other cases are true" do
    end
  end

  describe "#submission" do
    it "gets the submission from the submission_file" do
    end

    it "caches the submission" do
    end

    it "sets the submission to @submission" do
    end
  end

  describe "#assignment" do
    it "gets the assignment from the submission" do
    end

    it "caches the assignment" do
    end

    it "sets the assignment to @assignment" do
    end
  end
end
