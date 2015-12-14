require "active_record_spec_helper"
require "./app/exporters/grades_for_research_exporter"

describe GradesForResearchExporter do
  let(:course) { create :course }
  subject { GradesForResearchExporter.new }

  describe "#export" do
    it "generates an empty CSV if there are no students or assignments" do
      csv = subject.research_grades(course)
      expect(csv).to eq "Course ID,Uniqname,First Name,Last Name,GradeCraft ID,Assignment Name,Assignment ID,Assignment Type,Assignment Type Id,Score,Assignment Point Total,Multiplied Score,Predicted Score,Text Feedback,Submission ID,Submission Creation Date,Submission Updated Date,Graded By,Created At,Updated At\n"
    end
  end
end
