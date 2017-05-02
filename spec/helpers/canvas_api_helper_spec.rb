describe CanvasAPIHelper, focus: true do
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
end
