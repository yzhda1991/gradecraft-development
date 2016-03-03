require 'active_record_spec_helper'

describe SecureTokenAuthenticator do
  subject { described_class.new attributes }

  let(:attributes) {{
    secure_token_uuid: "some_uuid",
    target_class: "WaffleClass",
    secret_key: "skeletonkeysrsly"
  }}

  # def authenticates?
  #   options_valid? && secure_token && target_exists? && secure_token_authenticated?
  # end

  # protected

  # def options_valid?
  #   secure_token_uuid.present? && target_class.present? && secret_key.present?
  # end

  # def secure_token_found?
  #   @secure_token ||= SecureToken.find_by_uuid secure_token_uuid
  # end

  # def target_exists?
  #   @secure_token.has_target_of_class?(target_class)
  # end

  # def secure_token_authenticated?
  #   @secure_token.authenticates_with?(secret_key)
  # end

  describe "#initialize" do
    it "caches the uuid" do
      expect(subject.instance_variable_get(:@secure_token_uuid))
        .to eq("some_uuid")
    end

    it "caches the target class" do
      expect(subject.instance_variable_get(:@target_class))
        .to eq("WaffleClass")
    end

    it "caches the secret key" do
      expect(subject.instance_variable_get(:@secret_key))
        .to eq("skeletonkeysrsly")
    end
  end

  describe "readable attributes" do
    it "has a readable uuid" do
      expect(subject.secure_token_uuid).to eq("some_uuid")
    end

    it "has a readable target class" do
      expect(subject.target_class).to eq("WaffleClass")
    end

    it "has a readable secret_key" do
      expect(subject.secret_key).to eq("skeletonkeysrsly")
    end
  end

  describe "#authenticates?" do
    let(:result) { subject.authenticates? }

    before do
      allow(subject).to receive_messages(
        options_present?: true,
        secure_token_found?: true,
        target_exists?: true,
        secure_token_authenticated?: true
      )
    end

    context "all steps return true" do
      it "authenticates" do
        expect(result).to be_truthy
      end
    end

    context "options are not present" do
      it "does not authenticate" do
        allow(subject).to receive(:options_present?) { false }
        expect(result).to be_falsey
      end
    end

    context "the secure token is not found" do
      it "does not authenticate" do
        allow(subject).to receive(:secure_token_found?) { false }
        expect(result).to be_falsey
      end
    end

    context "the target does not exist" do
      it "does not authenticate" do
        allow(subject).to receive(:target_exists?) { false }
        expect(result).to be_falsey
      end
    end

    context "the secure token does not authenticate properly" do
      it "does not authenticate" do
        allow(subject).to receive(:secure_token_authenticated?) { false }
        expect(result).to be_falsey
      end
    end
  end

end
