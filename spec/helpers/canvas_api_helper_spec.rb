describe CanvasAPIHelper do
  subject { helper }

  describe "#concat_submission_comments" do
    it "returns nil if there are no comments" do
      expect(subject.concat_submission_comments([])).to be_nil
    end

    it "returns comments parsed and separated by the default separator" do
      comments = [{ "comment" => "good jorb" }, { "comment" => "excellent" }]
      expect(subject.concat_submission_comments(comments)).to eq \
        "Comment 1: good jorb; Comment 2: excellent"
    end
  end

  describe "#lms_user_role" do
    it "returns the observer role if no enrollments are given" do
      expect(subject.lms_user_role([])).to eq "observer"
    end

    it "returns the observer role if the only enrollment type is unrecognized" do
      enrollments = [{ "type" => "HackerEnrollment" }]
      expect(subject.lms_user_role(enrollments)).to eq "observer"
    end

    it "returns the translated Gradecraft role of highest precedence" do
      enrollments = [
        { "type" => "ObserverEnrollment", "enrollment_state" => "inactive" },
        { "type" => "TaEnrollment", "enrollment_state" => "active" },
        { "type" => "TeacherEnrollment", "enrollment_state" => "inactive" },
        { "type" => "DesignerEnrollment", "enrollment_state" => "active" },
        { "type" => "StudentEnrollment", "enrollment_state" => "active" }
      ]
      expect(subject.lms_user_role(enrollments)).to eq "gsi"
    end
  end
end
