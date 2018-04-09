describe SubmissionsHelper do
  let(:course) { create :course }

  describe "#resubmission_count_for" do
    let!(:student) { create(:course_membership, :student, course: course, active: true).user }
    let!(:grade) { create :student_visible_grade, course: course, student_id: student.id, submission: submission,
                   graded_at: 1.day.ago
                 }
    let!(:submission) { create :submission, student_id: student.id, course: course, submitted_at: DateTime.now }

    it "returns the number of resubmitted submissions" do
      expect(resubmission_count_for(course)).to eq 1
    end

    it "caches the result" do
      expect(course).to receive(:submissions).and_call_original.at_most(:twice)
      resubmission_count_for(course)
      resubmission_count_for(course)
      Rails.cache.delete resubmission_count_cache_key(course)
      resubmission_count_for(course)
    end
  end

  describe "#ungraded_submissions_count_for" do
    let!(:student) { create(:course_membership, :student, course: course, active: true).user }
    let!(:submission) { create :submission, course: course, student_id: student.id }
    let!(:draft_submission) { create :draft_submission, course: course, student_id: student.id }

    context "when not including draft submissions" do
      it "returns the number of ungraded draft submissions" do
        expect(ungraded_submissions_count_for(course)).to eq 1
      end
    end

    context "when including draft submissions" do
      it "returns the number of ungraded submissions" do
        expect(ungraded_submissions_count_for(course, true)).to eq 2
      end
    end

    it "caches the result" do
      expect(course).to receive(:submissions).and_call_original.at_most(:twice)
      ungraded_submissions_count_for(course)
      ungraded_submissions_count_for(course)
      Rails.cache.delete ungraded_submissions_count_cache_key(course)
      ungraded_submissions_count_for(course)
    end
  end

  describe "#submission_link_to" do
    let(:course) { build_stubbed :course }
    let(:student) { build_stubbed :user, courses: [course], role: :student }

    before(:each) do
      allow(helper).to receive(:current_course).and_return course
      allow(helper).to receive(:current_student).and_return student
      allow(helper).to receive(:current_user).and_return student
    end

    context "when the assignment is group-graded" do
      let(:assignment) { build_stubbed :group_assignment, course: course }
      let(:group) { build_stubbed :approved_group, course: course }
      let!(:group_membership) { build_stubbed :group_membership, student: student, course: course, group: group }

      before(:each) { allow(student).to receive(:group_for_assignment).with(assignment).and_return group }

      context "when no submission is present for the student" do
        it "returns nothing if the assignment is closed" do
          allow(assignment).to receive(:open?).and_return false
          expect(helper.submission_link_to(assignment, student)).to be_nil
        end

        it "returns nothing if the course is closed" do
          course.status = false
          expect(helper.submission_link_to(assignment, student)).to be_nil
        end

        it "returns nothing if the student belongs to an unapproved group" do
          group.approved = "Pending"
          expect(helper.submission_link_to(assignment, student)).to be_nil
        end

        it "returns a link to create a submission" do
          expect(helper.submission_link_to(assignment, student)).to include "Submit"
          expect(helper.submission_link_to(assignment, student)).to include \
            submit_assignment_submission_path(assignment, student)
        end
      end

      context "when a submission is present for the student" do
        let!(:submission) { build_stubbed :submission, course: course, assignment: assignment, group: group }

        before(:each) { allow(helper).to receive(:submission_for).with(assignment, student).and_return submission }

        it "returns nothing if the submission is not visible" do
          proctor = instance_double "SubmissionProctor", viewable?: false
          allow(SubmissionProctor).to receive(:new).with(submission).and_return proctor
          expect(helper.submission_link_to(assignment, student)).to be_nil
        end

        it "returns a link to edit the submission if it's editable" do
          proctor = instance_double "SubmissionProctor", viewable?: true, open_for_editing?: true
          allow(SubmissionProctor).to receive(:new).with(submission).and_return proctor
          expect(helper.submission_link_to(assignment, student)).to include \
            edit_assignment_submission_path(assignment, submission)
        end

        it "returns a link to see the submission if it's not editable" do
          proctor = instance_double "SubmissionProctor", viewable?: true, open_for_editing?: false
          allow(SubmissionProctor).to receive(:new).with(submission).and_return proctor
          expect(helper.submission_link_to(assignment, student)).to include \
            see_submission_path(submission)
        end
      end
    end

    context "when the assignment is individually graded" do
      let(:assignment) { build_stubbed :individual_assignment, course: course }

      it "returns a link to create a submission" do
        expect(helper.submission_link_to(assignment, student)).to include \
          new_assignment_submission_path(assignment, student_id: student.id)
      end
    end
  end
end
