require "./lib/lms_importer"

describe LMSImporter::CourseImporter do
  let(:access_token) { "BLAH" }

  describe "#initialize" do
    it "initializes with a provider" do
      expect(described_class.new(:canvas, access_token).provider).to \
        be_kind_of LMSImporter::CanvasCourseImporter
    end

    it "raises an InvalidProviderError with an invalid provider name" do
      expect { described_class.new(:blah, access_token) }.to \
        raise_error LMSImporter::InvalidProviderError, "blah is not a supported provider"
    end
  end
end
