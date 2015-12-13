require "active_record_spec_helper"
require "./app/exporters/gradebook_exporter"

describe GradebookExporter, focus: true do
  let(:course) { create :course }
  subject { GradebookExporter.new }

  describe "#export" do
    it "generates an empty CSV if there are no students or assignments" do
      csv = subject.gradebook(course.id)
      expect(csv).to eq "First Name,Last Name,Email,Username,Team\n"
    end
  end
end
