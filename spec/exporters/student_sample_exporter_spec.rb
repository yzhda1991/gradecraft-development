describe StudentSampleExporter, focus: true do

  subject { StudentSampleExporter.new }

  describe "#generate_csv" do
    it "generates a CSV with a header and two sample students" do
      csv = subject.generate_csv
      expect(csv).to include "First Name", "Last Name", "Username", "Email", "Team Name"
    end
  end

end
