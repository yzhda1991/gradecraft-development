require "active_record_spec_helper"
require "./app/importers/grade_importers/canvas_grade_importer"

describe CanvasGradeImporter do
  describe "#import" do
    it "returns empty results if there are no canvas grades" do
      result = described_class.new(nil).import(nil, nil)

      expect(result.successful).to be_empty
      expect(result.unsuccessful).to be_empty
    end

    context "with some canvas grades" do
      let(:assignment) { create :assignment }
      let(:canvas_grade) do
        {
          id: canvas_grade_id,
          score: 98.0,
          user_id: "USER_1"
        }.stringify_keys
      end
      let(:canvas_user) do
        {
          primary_email: user.email
        }.stringify_keys
      end
      let(:canvas_grade_id) { "GRADE_1" }
      let(:grade) { Grade.unscoped.last }
      let(:syllabus) { double(:syllabus, user: canvas_user) }
      let(:user) { create :user }
      subject { described_class.new([canvas_grade]) }

      it "creates the grade" do
        expect { subject.import(assignment.id, syllabus) }.to \
          change { Grade.count }.by 1
        expect(grade.assignment).to eq assignment
        expect(grade.student).to eq user
        expect(grade.raw_points).to eq 98
      end
    end
  end
end
