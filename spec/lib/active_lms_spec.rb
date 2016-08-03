require "./lib/active_lms"

describe ActiveLMS do
  describe ".configure" do
    it "sets the configuration for ActiveLMS" do
      ActiveLMS.configure do |config|
        config.provider :canvas do |canvas|
          canvas.client_id = "CLIENT ID"
          canvas.client_secret = "CLIENT SECRET"
          canvas.client_options = {
            site: "SITE"
          }
        end
      end

      expect(ActiveLMS.configuration.providers.count).to eq 1
      expect(ActiveLMS.configuration.providers[:canvas].client_id).to eq "CLIENT ID"
      expect(ActiveLMS.configuration.providers[:canvas].client_secret).to eq "CLIENT SECRET"
      expect(ActiveLMS.configuration.providers[:canvas].client_options[:site]).to eq "SITE"
    end
  end
end
