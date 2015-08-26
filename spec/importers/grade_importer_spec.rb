require 'active_record_spec_helper'
require './app/importers/grade_importer'

describe GradeImporter do
  describe "#import" do
    it "returns empty results when there is no file" do
      result = GradeImporter.new(nil).import
      expect(result.successful).to be_empty
      expect(result.unsuccessful).to be_empty
    end

    context "with a file" do
      xit "does not create a grade if the student does not exist"
      xit "creates the grade if it is not there"
      xit "updates the grade if it is already there"
      xit "creates a grade for a student by unique name"
    end
  end
end
