describe GradesHelper do
  let(:course) { create :course }

  describe "#in_progress_grades_count_for" do
    let!(:student) { create(:course_membership, :student, course: course, active: true).user }
    let!(:grade) { create :in_progress_grade, course: course, student_id: student.id }

    it "returns the number of grades that are in progress" do
      expect(in_progress_grades_count_for(course)).to eq 1
    end

    it "caches the result" do
      expect(course).to receive(:grades).and_call_original.at_most(:twice)
      in_progress_grades_count_for(course)
      in_progress_grades_count_for(course)
      Rails.cache.delete in_progress_grades_count_cache_key(course)
      in_progress_grades_count_for(course)
    end
  end

  describe "#ready_for_release_grades_count_for" do
    let(:assignment) { create :assignment, course: course }
    let!(:student) { create(:course_membership, :student, course: course, active: true).user }
    let!(:grade) { create :complete_grade, assignment: assignment, course: course, student_id: student.id }

    it "returns the number of grades that are unreleased" do
      expect(ready_for_release_grades_count_for(course)).to eq 1
    end

    it "caches the result" do
      expect(course).to receive(:grades).and_call_original.at_most(:twice)
      ready_for_release_grades_count_for(course)
      ready_for_release_grades_count_for(course)
      Rails.cache.delete ready_for_release_count_cache_key(course)
      ready_for_release_grades_count_for(course)
    end
  end

  describe "#grading_status_count_for" do
    class Helper
      include GradesHelper
    end

    let(:helper) { Helper.new }

    it "returns the sum of unreleased grades, in progress grades, and ungraded submissions" do
      allow(helper).to receive(:ungraded_submissions_count_for).with(course).and_return 10
      allow(helper).to receive(:ready_for_release_grades_count_for).with(course).and_return 20
      allow(helper).to receive(:in_progress_grades_count_for).with(course).and_return 30
      allow(helper).to receive(:resubmission_count_for).with(course).and_return 2
      expect(helper.grading_status_count_for(course)).to eq 62
    end
  end

  describe "#pass_fail_status_for" do
    it "returns pass if the score is 1" do
      expect(helper.pass_fail_status_for(1)).to eq "Pass"
    end

    it "returns fail if the score is 0" do
      expect(helper.pass_fail_status_for(0)).to eq "Fail"
    end

    it "returns nil if the score is neither 1 nor 0" do
      expect(helper.pass_fail_status_for(123)).to be_nil
    end
  end
end
