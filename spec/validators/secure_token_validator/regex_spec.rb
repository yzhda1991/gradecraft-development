describe SecureTokenValidator::Regex do
  describe ".uuid" do
    it "matches standard UUIDs" do
      expect(described_class.uuid).to match SecureRandom.uuid
    end
  end

  describe ".secret_key" do
    it "matches strings of 254-character 190-bit secret keys" do
      expect(described_class.secret_key)
        .to match SecureRandom.urlsafe_base64(190)
    end
  end
end
