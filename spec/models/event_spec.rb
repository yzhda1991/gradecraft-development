describe Event do
  subject { build(:event) }

  describe "validations" do
    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end
  end
end
