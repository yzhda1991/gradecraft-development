require "rails_spec_helper"

describe GradeExporter do
  subject { GradeExporter.new }

  describe "#export" do
    it "generates an empty CSV if there is no assignment specified" do
      csv = subject.export(nil, [])
      expect(csv.read.length) == 1 # headers
    end

    xit "generates an empty CSV if there are no students specified"
    xit "generates a CSV with student scores"
  end
end
