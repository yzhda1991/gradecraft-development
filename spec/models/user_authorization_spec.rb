require "active_record_spec_helper"

describe UserAuthorization do
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
