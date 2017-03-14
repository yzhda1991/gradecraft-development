describe SubmissionFileProctor do
  subject { described_class.new submission_file }
  let(:submission_file) { double(:submission_file, submission: submission) }
  let(:course) { double(:course).as_null_object }
  let(:assignment) { double(:assignment).as_null_object }
  let(:submission) do
    double :submission, assignment: assignment, course: course
  end

  let(:proctor_conditions) do
    Proctors::SubmissionFileConditionSet.new proctor: subject
  end

  describe "readable attributes" do
    it "has a readable submission file" do
      expect(subject.submission_file).to eq submission_file
    end
  end

  describe "#initialize" do
    it "sets the given submission_file to @submission_file" do
      expect(subject.instance_variable_get :@submission_file)
        .to eq submission_file
    end
  end

  describe "#downloadable_by?" do
    let(:result) { subject.downloadable_by? user }
    let(:user) { double(:user) }
    let(:downloadable_conditions) { double(:downloadable).as_null_object }

    before do
      allow(subject).to receive(:proctor_conditions) { proctor_conditions }
      allow(proctor_conditions).to receive(:for) { downloadable_conditions }
    end

    it "gets the proctor conditions for downloadable" do
      expect(proctor_conditions).to receive(:for).with(:downloadable)
      result
    end

    it "checks whether the downloadable conditions are satisfied by the user" do
      expect(downloadable_conditions).to receive(:satisfied_by?).with user
      result
    end
  end

  describe "#proctor_conditions" do
    let(:result) { subject.proctor_conditions }

    # @proctor_conditions ||= Proctors::SubmissionFileConditionSet.new(proctor: self)
    it "builds a new set of conditions for the submission file proctor" do
      expect(Proctors::SubmissionFileConditionSet).to receive(:new)
        .with(proctor: subject)
      result
    end

    it "caches the proctor_conditions" do
      result
      expect(Proctors::SubmissionFileConditionSet).not_to receive(:new)
      result
    end

    it "sets the proctor conditions to @proctor_conditions" do
      allow(Proctors::SubmissionFileConditionSet).to receive(:new) { "stuff" }
      result
      expect(subject.instance_variable_get :@proctor_conditions).to eq "stuff"
    end
  end

  describe "#course" do
    let(:result) { subject.course }

    before do
      allow(submission).to receive(:course) { course }
    end

    it "gets the course from the submission" do
      expect(result).to eq course
    end

    it "caches the course" do
      result
      expect(submission).not_to receive(:course)
      result
    end

    it "sets the course to @course" do
      result
      expect(subject.instance_variable_get :@course).to eq course
    end
  end

  describe "#submission" do
    let(:result) { subject.submission }

    before do
      allow(submission_file).to receive(:submission) { submission }
    end

    it "gets the submission from the submission_file" do
      expect(result).to eq submission
    end

    it "caches the submission" do
      result
      expect(submission_file).not_to receive(:submission)
      result
    end

    it "sets the submission to @submission" do
      result
      expect(subject.instance_variable_get :@submission).to eq submission
    end
  end

  describe "#assignment" do
    let(:result) { subject.assignment }

    before do
      allow(submission).to receive(:assignment) { assignment }
    end

    it "gets the assignment from the submission" do
      expect(result).to eq assignment
    end

    it "caches the assignment" do
      result
      expect(submission).not_to receive(:assignment)
      result
    end

    it "sets the assignment to @assignment" do
      result
      expect(subject.instance_variable_get :@assignment).to eq assignment
    end
  end
end
