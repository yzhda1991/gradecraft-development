describe Provider do
  subject { create :provider, consumer_secret: "password1" }

  describe "callbacks" do
    it "encrypts and stores the consumer key" do
      expect(subject).to receive(:encrypt_consumer_secret)
      subject.save
      expect(subject).to_not eq "password1"
    end
  end

  describe "#consumer_secret" do
    it "returns the decrypted key" do
      expect(subject.decrypted_consumer_secret).to eq "password1"
    end
  end
end
