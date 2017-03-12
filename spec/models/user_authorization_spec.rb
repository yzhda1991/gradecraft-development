require "api_spec_helper"

describe UserAuthorization, type: :disable_external_api do
  describe ".create_by_auth_hash" do
    let(:canvas_auth_hash) do
      {
        provider: "canvas",
        credentials: {
          token: "BLAH",
          refresh_token: "REFRESH",
          expires_at: expires_at.to_i,
          expires: true
        }
      }.deep_stringify_keys
    end
    let(:expires_at) { Time.now + (30 * 24 * 60 * 60) }
    let(:user) { create :user }

    it "creates an authorization for the specified user" do
      authorization = described_class.create_by_auth_hash canvas_auth_hash, user

      expect(authorization).to_not be_nil
      expect(authorization.user_id).to eq user.id
      expect(authorization.provider).to eq "canvas"
      expect(authorization.access_token).to eq "BLAH"
      expect(authorization.refresh_token).to eq "REFRESH"
      expect(authorization.expires_at.to_i).to eq expires_at.to_i
    end

    it "updates the authorization information if one already exists" do
      create :user_authorization, :canvas, user: user, access_token: "BLEH"

      authorization = described_class.create_by_auth_hash canvas_auth_hash, user

      expect(authorization.access_token).to eq "BLAH"
    end
  end

  describe "#expired?" do
    it "returns true if the authorization expiration date is in the past" do
      subject.expires_at = 2.days.ago

      expect(subject).to be_expired
    end

    it "returns false if the authorization expiration date is in the future" do
      subject.expires_at = 2.days.from_now

      expect(subject).to_not be_expired
    end
  end

  describe ".for" do
    let(:user) { create :user }

    it "returns the authorization for the specific user and provider" do
      authorization = create :user_authorization, :canvas, user: user

      expect(described_class.for(user, :canvas)).to eq authorization
    end

    it "returns nil if the authorization does not exist" do
      expect(described_class.for(user, :canvas)).to be_nil
    end
  end

  describe "#refresh!" do
    let(:response) do
      {
        access_token: "NEW_TOKEN",
        refresh_token: "CHANGED!",
        expires_in: 3600
      }.deep_stringify_keys
    end
    subject { build :user_authorization, :canvas, refresh_token: "REFRESH" }

    before do
      @request = stub_request(:post, "https://canvas.instructure.com/login/oauth2/token")
        .with(body: { "client_id" => "CLIENT_ID", "client_secret" => "SECRET",
                      "grant_type" => "refresh_token", "refresh_token" => "REFRESH" })
        .to_return(status: 200, body: URI.encode_www_form(response),
                   headers: { "Content-Type" => "application/x-www-form-urlencoded" })
    end

    it "receives a new access token from the provider" do
      allow(OmniAuth::Strategies).to receive(:const_get).with("Canvas")
        .and_return(OmniAuth::Strategies::Canvas)
      subject.refresh!({ client_id: "CLIENT_ID", client_secret: "SECRET" })

      expect(subject.reload.access_token).to eq "NEW_TOKEN"
      expect(subject.refresh_token).to eq "CHANGED!"
      expect(subject.expires_at).to be > DateTime.now
    end

    it "does not make an call to the provider if the refresh token is not available" do
      subject.refresh_token = nil

      subject.refresh!({ client_id: "CLIENT_ID", client_secret: "SECRET" })

      expect(@request).to_not have_been_made
    end
  end

  describe "#refresh_with_config!" do
    let(:config) { double(:config,
                          client_id: "CLIENT",
                          client_secret: "SECRET",
                          client_options: {}) }

    it "refreshes the access token with the configuration options" do
      expect(subject).to receive(:refresh!)
        .with({ client_id: "CLIENT", client_secret: "SECRET", client_options: {} })

      subject.refresh_with_config!(config)
    end
  end
end
