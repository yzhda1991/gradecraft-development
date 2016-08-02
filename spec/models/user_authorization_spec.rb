require "active_record_spec_helper"

describe UserAuthorization do
  describe ".create_by_auth_hash" do
    let(:canvas_auth_hash) do
      {
        provider: "canvas",
        credentials: {
          token: "BLAH",
          expires_at: (Time.now + (30 * 24 * 60 * 60)).to_i,
          expires: true
        }
      }.deep_stringify_keys
    end
    let(:user) { create :user }

    it "creates an authorization for the specified user" do
      authorization = described_class.create_by_auth_hash canvas_auth_hash, user

      expect(authorization).to_not be_nil
      expect(authorization.user_id).to eq user.id
      expect(authorization.provider).to eq "canvas"
      expect(authorization.access_token).to eq "BLAH"
    end

    it "updates the authorization information if one already exists" do
      create :user_authorization, :canvas, user: user, access_token: "BLEH"

      authorization = described_class.create_by_auth_hash canvas_auth_hash, user

      expect(authorization.access_token).to eq "BLAH"
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
end
