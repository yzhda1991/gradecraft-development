require "active_record_spec_helper"
require "./app/exporters/multiplied_gradebook_exporter"

describe MultipliedGradebookExporter do
  let(:course) { create :course }
  subject { MultipliedGradebookExporter.new }

  describe "#export" do
    it "generates an empty CSV if there are no students or assignments" do
      csv = subject.multiplied_gradebook(course.id)
      expect(csv).to eq "First Name,Last Name,Email,Username,Team\n"
    end
  end
end
