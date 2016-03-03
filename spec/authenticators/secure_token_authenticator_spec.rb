require 'active_record_spec_helper'
require_relative "../../app/authenticators/secure_token_authenticator"
require_relative "../../config/initializers/regex" unless defined? REGEX

describe SecureTokenAuthenticator do
  subject { described_class.new attributes }

  let(:attributes) {{
    secure_token_uuid: "some_uuid",
    target_class: "WaffleClass",
    secret_key: "skeletonkeysrsly"
  }}
  let(:secure_token) { SecureToken.new }

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
    let(:secure_token) { SecureToken.new }

    before(:each) do
      allow(subject).to receive_messages(
        uuid_format_valid?: true,
        secure_key_format_valid?: true,
        secure_token: secure_token,
        secret_key: "the-secret-key"
      )

      allow(secure_token).to receive(:authenticates_with?)
        .with("the-secret-key").and_return true
    end

    context "all steps return true" do
      it "authenticates" do
        expect(result).to be_truthy
      end
    end

    context "the uuid format is not valid" do
      it "does not authenticate" do
        allow(subject).to receive(:uuid_format_valid?) { false }
        expect(result).to be_falsey
      end
    end

    context "the secure key format is not valid" do
      it "does not authenticate" do
        allow(subject).to receive(:secure_key_format_valid?) { false }
        expect(result).to be_falsey
      end
    end

    context "the secure token isn't present" do
      it "does not authenticate" do
        allow(subject).to receive(:secure_token) { nil }
        expect(result).to be_falsey
      end
    end

    context "the secure token doesn't authenticate with the given secret key" do
      before(:each) do
        allow(secure_token).to receive(:authenticates_with?)
          .with("the-secret-key").and_return false
      end

      it "does not authenticate" do
        expect(result).to be_falsey
      end
    end
  end

  describe "#secure_token" do
    let(:result) { subject.secure_token }

    # it's pretty much impossible for there to be multiple secure tokens with
    # the same uuid and target class since the uuid values are being generated
    # by the SecureRandom library, and the uuid value is intended always to be a
    # unique value, but since it's technically possible let's test for it anyway
    # to ensure we don't encounter any unexpected regressions here
    #
    before(:each) do
      # let's make sure that there aren't any instance variables screwing with
      # us between examples
      subject.instance_variable_set(:@secure_token, nil)
    end

    context "multiple secure tokens exist with the uuid and target class" do
      let(:secure_token) do
        # the attributes being used to build this secure token match the stubbed
        # values being passed into the subject at the top of the spec, so this
        # secure token matches the default subject attributes
        #
        SecureToken.create target_type: attributes[:target_class]
      end

      it "returns the first secure token matching this pair" do
        allow(subject).to receive(:secure_token_uuid) { secure_token.uuid }
        expect(result).to eq(secure_token)
      end
    end

    context "no secure tokens exist for the uuid and target class" do
      let(:attributes) do
        { secure_token_uuid: "doesnt-exist", target_class: "NotAClass" }
      end

      it "doesn't find anything and returns nil" do
        expect(result).to be_nil
      end
    end
  end
end
