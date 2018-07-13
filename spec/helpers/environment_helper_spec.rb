describe EnvironmentHelper do
  include UniMock::StubRails

  describe "#environment_to_readable_s" do
    it "returns 'Umich' if the environment is production" do
      stub_env "production"
      expect(helper.environment_to_readable_s).to eq "Umich"
    end

    it "returns 'App' if the environment is beta" do
      stub_env "beta"
      expect(helper.environment_to_readable_s).to eq "App"
    end

    it "returns the environment as a capitalized string if it is not beta or production" do
      stub_env "test"
      expect(helper.environment_to_readable_s).to eq "Test"
    end
  end
end
