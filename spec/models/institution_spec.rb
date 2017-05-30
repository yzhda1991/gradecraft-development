describe Institution do
  subject { Institution.create }

  context "validations" do
    it "is invalid if the name has already been taken" do
      Institution.create name: "umich"
      subject.name = "umich"
      expect(subject).to_not be_valid
    end
  end
end
