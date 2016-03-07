require "rails_spec_helper"
require "./app/helpers/link_helper"

describe LinkHelper do
  include RSpecHtmlMatchers

  let!(:target) { create(:submissions_export) }
  let!(:secure_token) { SecureToken.create target: target }

  describe "#secure_download_url" do
    let(:result) { helper.secure_download_url(secure_token) }

    it "returns a secure download link for the SecureToken target" do
      expect(result).to eq (
        "http://test.host/secure_downloads/submissions_exports/" \
          "#{secure_token.uuid}/secret_key/#{secure_token.random_secret_key}"
      )
    end
  end
end
